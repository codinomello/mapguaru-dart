package main

import (
	"crypto/tls"
	"encoding/json"
	"encoding/xml"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"os"
	"strings"
	"time"

	"github.com/spf13/cobra"
)

const (
	baseURL = "https://geonetwork.guarulhos.sp.gov.br:8443/geonetwork"
)

// Estruturas XML do GeoNetwork
type XMLResponse struct {
	XMLName  xml.Name      `xml:"response"`
	From     string        `xml:"from,attr"`
	To       string        `xml:"to,attr"`
	Selected string        `xml:"selected,attr"`
	Summary  XMLSummary    `xml:"summary"`
	Metadata []XMLMetadata `xml:"metadata"`
}

type XMLSummary struct {
	Count string `xml:"count,attr"`
	Type  string `xml:"type,attr"`
}

type XMLMetadata struct {
	Title      string     `xml:"title"`
	Abstract   string     `xml:"abstract"`
	GeonetInfo GeonetInfo `xml:"geonet>info"`
}

type GeonetInfo struct {
	UUID       string `xml:"uuid"`
	Schema     string `xml:"schema"`
	CreateDate string `xml:"createDate"`
	ChangeDate string `xml:"changeDate"`
	Source     string `xml:"source"`
	Type       string `xml:"type"`
}

// SearchResponse estrutura de resposta
type SearchResponse struct {
	Hits HitsContainer `json:"hits"`
}

type HitsContainer struct {
	Total    TotalHits `json:"total"`
	MaxScore float64   `json:"max_score"`
	Hits     []Hit     `json:"hits"`
}

type TotalHits struct {
	Value    int    `json:"value"`
	Relation string `json:"relation"`
}

type Hit struct {
	Index  string                 `json:"_index"`
	Type   string                 `json:"_type"`
	ID     string                 `json:"_id"`
	Score  float64                `json:"_score"`
	Source map[string]interface{} `json:"_source"`
}

// GeoNetworkClient cliente HTTP personalizado
type GeoNetworkClient struct {
	httpClient *http.Client
	baseURL    string
}

func NewGeoNetworkClient() *GeoNetworkClient {
	tr := &http.Transport{
		TLSClientConfig: &tls.Config{InsecureSkipVerify: true},
	}
	return &GeoNetworkClient{
		httpClient: &http.Client{
			Transport: tr,
			Timeout:   30 * time.Second,
		},
		baseURL: baseURL,
	}
}

func (c *GeoNetworkClient) Search(query string, from, size int) (*SearchResponse, error) {
	searchURL := fmt.Sprintf("%s/srv/por/xml.search", c.baseURL)

	params := url.Values{}
	params.Add("fast", "index")
	params.Add("from", fmt.Sprintf("%d", from+1))
	params.Add("to", fmt.Sprintf("%d", from+size))
	params.Add("buildSummary", "true")

	if query != "" {
		params.Add("any", query)
	}

	fullURL := fmt.Sprintf("%s?%s", searchURL, params.Encode())

	req, err := http.NewRequest("GET", fullURL, nil)
	if err != nil {
		return nil, fmt.Errorf("erro ao criar requisicao: %w", err)
	}

	req.Header.Set("Accept", "application/xml")

	resp, err := c.httpClient.Do(req)
	if err != nil {
		return nil, fmt.Errorf("erro ao fazer requisicao: %w", err)
	}
	defer resp.Body.Close()

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, fmt.Errorf("erro ao ler resposta: %w", err)
	}

	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("erro na API (status %d): %s", resp.StatusCode, string(body))
	}

	return c.parseXMLResponse(body)
}

func (c *GeoNetworkClient) parseXMLResponse(body []byte) (*SearchResponse, error) {
	var xmlResp XMLResponse
	if err := xml.Unmarshal(body, &xmlResp); err != nil {
		return nil, fmt.Errorf("erro ao parsear XML: %w", err)
	}

	searchResp := &SearchResponse{
		Hits: HitsContainer{
			Total: TotalHits{
				Value:    parseIntOrZero(xmlResp.Summary.Count),
				Relation: "eq",
			},
			Hits: []Hit{},
		},
	}

	for _, meta := range xmlResp.Metadata {
		hit := Hit{
			Index: "gn-records",
			Type:  "_doc",
			ID:    meta.GeonetInfo.UUID,
			Score: 1.0,
			Source: map[string]interface{}{
				"uuid":         meta.GeonetInfo.UUID,
				"title":        meta.Title,
				"abstract":     meta.Abstract,
				"changeDate":   meta.GeonetInfo.ChangeDate,
				"createDate":   meta.GeonetInfo.CreateDate,
				"resourceType": []string{meta.GeonetInfo.Type},
				"schema":       meta.GeonetInfo.Schema,
				"source":       meta.GeonetInfo.Source,
			},
		}
		searchResp.Hits.Hits = append(searchResp.Hits.Hits, hit)
	}

	return searchResp, nil
}

func parseIntOrZero(s string) int {
	var i int
	fmt.Sscanf(s, "%d", &i)
	return i
}

var statsCmd = &cobra.Command{
	Use:   "stats",
	Short: "Mostra estatisticas e categorias disponiveis no catalogo",
	Run: func(cmd *cobra.Command, args []string) {
		client := NewGeoNetworkClient()

		// Busca todos para ver as categorias
		resp, err := client.Search("", 0, 100)
		if err != nil {
			fmt.Fprintf(os.Stderr, "Erro: %v\n", err)
			os.Exit(1)
		}

		fmt.Printf("\n=== ESTATISTICAS DO CATALOGO ===\n")
		fmt.Printf("Total de registros: %d\n\n", resp.Hits.Total.Value)

		// Agrupa por tipo
		types := make(map[string]int)
		schemas := make(map[string]int)
		titles := []string{}

		for _, hit := range resp.Hits.Hits {
			if resourceType, ok := hit.Source["resourceType"].([]string); ok && len(resourceType) > 0 {
				types[resourceType[0]]++
			}
			if schema, ok := hit.Source["schema"].(string); ok && schema != "" {
				schemas[schema]++
			}
			if title, ok := hit.Source["title"].(string); ok && title != "" {
				titles = append(titles, title)
			}
		}

		fmt.Println("=== TIPOS DE RECURSOS ===")
		for typ, count := range types {
			fmt.Printf("  %s: %d registros\n", typ, count)
		}

		fmt.Println("\n=== SCHEMAS ===")
		for schema, count := range schemas {
			fmt.Printf("  %s: %d registros\n", schema, count)
		}

		fmt.Println("\n=== EXEMPLOS DE TITULOS (primeiros 10) ===")
		for i, title := range titles {
			if i >= 10 {
				break
			}
			if len(title) > 70 {
				title = title[:70] + "..."
			}
			fmt.Printf("  %d. %s\n", i+1, title)
		}

		fmt.Println("\n=== DICAS DE BUSCA ===")
		fmt.Println("Voce pode buscar por:")
		fmt.Println("  - Palavras-chave: geonetwork-cli search \"hidrografia\"")
		fmt.Println("  - Multiplas palavras: geonetwork-cli search \"uso do solo\"")
		fmt.Println("  - Termos especificos dos titulos acima")
		fmt.Println("  - Temas: educacao, saude, ambiental, etc.")
		fmt.Println()
	},
}

var rootCmd = &cobra.Command{
	Use:   "geonetwork-cli",
	Short: "CLI para consumir a API do GeoNetwork de Guarulhos",
	Long:  "Ferramenta de linha de comando para buscar e visualizar dados geograficos do catalogo de Guarulhos.",
}

var searchCmd = &cobra.Command{
	Use:   "search [query]",
	Short: "Busca registros no catalogo",
	Long:  "Realiza uma busca no catalogo GeoNetwork usando uma query string.",
	Args:  cobra.MinimumNArgs(1),
	Run: func(cmd *cobra.Command, args []string) {
		query := strings.Join(args, " ")
		from, _ := cmd.Flags().GetInt("from")
		size, _ := cmd.Flags().GetInt("size")
		format, _ := cmd.Flags().GetString("format")

		client := NewGeoNetworkClient()

		resp, err := client.Search(query, from, size)
		if err != nil {
			fmt.Fprintf(os.Stderr, "Erro: %v\n", err)
			os.Exit(1)
		}

		displayResults(resp, format)
	},
}

var listCmd = &cobra.Command{
	Use:   "list",
	Short: "Lista todos os registros do catalogo",
	Run: func(cmd *cobra.Command, args []string) {
		from, _ := cmd.Flags().GetInt("from")
		size, _ := cmd.Flags().GetInt("size")
		format, _ := cmd.Flags().GetString("format")

		client := NewGeoNetworkClient()

		resp, err := client.Search("", from, size)
		if err != nil {
			fmt.Fprintf(os.Stderr, "Erro: %v\n", err)
			os.Exit(1)
		}

		displayResults(resp, format)
	},
}

var getCmd = &cobra.Command{
	Use:   "get [uuid]",
	Short: "Obtem detalhes de um registro especifico por UUID",
	Args:  cobra.ExactArgs(1),
	Run: func(cmd *cobra.Command, args []string) {
		uuid := args[0]
		format, _ := cmd.Flags().GetString("format")

		client := NewGeoNetworkClient()

		resp, err := client.Search(uuid, 0, 1)
		if err != nil {
			fmt.Fprintf(os.Stderr, "Erro: %v\n", err)
			os.Exit(1)
		}

		if len(resp.Hits.Hits) == 0 {
			fmt.Printf("Nenhum registro encontrado com UUID: %s\n", uuid)
			return
		}

		displayResults(resp, format)
	},
}

func displayResults(resp *SearchResponse, format string) {
	switch format {
	case "json":
		data, _ := json.MarshalIndent(resp, "", "  ")
		fmt.Println(string(data))
	case "compact":
		displayCompact(resp)
	default:
		displayPretty(resp)
	}
}

func displayPretty(resp *SearchResponse) {
	fmt.Printf("\nTotal de registros: %d\n", resp.Hits.Total.Value)
	fmt.Printf("Resultados exibidos: %d\n\n", len(resp.Hits.Hits))
	fmt.Println(strings.Repeat("=", 80))

	for i, hit := range resp.Hits.Hits {
		fmt.Printf("\n[Registro #%d]\n", i+1)
		fmt.Printf("   UUID: %s\n", hit.ID)
		fmt.Printf("   Score: %.2f\n", hit.Score)
		fmt.Println("   ---")

		if title, ok := hit.Source["title"].(string); ok && title != "" {
			fmt.Printf("   Titulo: %s\n", title)
		}

		if abstract, ok := hit.Source["abstract"].(string); ok && abstract != "" {
			abstractText := abstract
			if len(abstractText) > 200 {
				abstractText = abstractText[:200] + "..."
			}
			fmt.Printf("   Resumo: %s\n", abstractText)
		}

		if resourceType, ok := hit.Source["resourceType"].([]string); ok && len(resourceType) > 0 {
			fmt.Printf("   Tipo: %s\n", resourceType[0])
		}

		if changeDate, ok := hit.Source["changeDate"].(string); ok && changeDate != "" {
			fmt.Printf("   Modificado: %s\n", changeDate)
		}

		if schema, ok := hit.Source["schema"].(string); ok && schema != "" {
			fmt.Printf("   Schema: %s\n", schema)
		}

		fmt.Println(strings.Repeat("-", 80))
	}
}

func displayCompact(resp *SearchResponse) {
	fmt.Printf("Total: %d registros\n\n", resp.Hits.Total.Value)

	for _, hit := range resp.Hits.Hits {
		title := "Sem titulo"
		if t, ok := hit.Source["title"].(string); ok && t != "" {
			title = t
		}
		fmt.Printf("[%s] %s\n", hit.ID, title)
	}
}

func init() {
	searchCmd.Flags().IntP("from", "f", 0, "Indice inicial dos resultados")
	searchCmd.Flags().IntP("size", "s", 10, "Numero de resultados")
	searchCmd.Flags().String("format", "pretty", "Formato de saida: pretty, compact, json")

	listCmd.Flags().IntP("from", "f", 0, "Indice inicial dos resultados")
	listCmd.Flags().IntP("size", "s", 10, "Numero de resultados")
	listCmd.Flags().String("format", "pretty", "Formato de saida: pretty, compact, json")

	getCmd.Flags().String("format", "pretty", "Formato de saida: pretty, compact, json")

	rootCmd.AddCommand(searchCmd)
	rootCmd.AddCommand(listCmd)
	rootCmd.AddCommand(getCmd)
	rootCmd.AddCommand(statsCmd)
}

func main() {
	if err := rootCmd.Execute(); err != nil {
		fmt.Fprintf(os.Stderr, "Erro: %v\n", err)
		os.Exit(1)
	}
}
