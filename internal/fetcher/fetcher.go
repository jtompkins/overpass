package fetcher

import (
	"io"
	"net/http"
	"net/url"
	"os"
	"path/filepath"
	"strings"

	"github.com/PuerkitoBio/goquery"
	"github.com/go-shiori/go-readability"
	"github.com/google/uuid"
	"github.com/rs/zerolog/log"
)

func FetchArticle(address string, tempPath string) (*ReadableArticle, error) {
	log.Info().Str("url", address).Str("temp path", tempPath).Msg("Fetching URL")

	readableArticle, err := fetchReadableHtml(address)

	if err != nil {
		return nil, err
	}

	doc, err := goquery.NewDocumentFromReader(strings.NewReader(readableArticle.Content))

	if err != nil {
		log.Error().Err(err).Msg("Failed to create goquery document")
		return nil, err
	}

	articleTempPath, err := os.MkdirTemp(tempPath, uuid.NewString())

	if err != nil {
		log.Error().Err(err).Str("article temp path", articleTempPath).Msg("Failed to create temporary path for article")
	}

	log.Debug().Str("article temp path", articleTempPath).Msg("Created temporary path for article")

	doc.Find("img").EachWithBreak(func(i int, s *goquery.Selection) bool {
		href, exists := s.Attr("src")

		if !exists {
			return true
		}

		log.Debug().Str("img src", href).Msg("found image")

		outputFilename, err := fetchImage(href, articleTempPath)

		if err != nil {
			log.Error().Str("img path", href).Err(err).Msg("Failed to fetch image")

			return false
		}

		readableArticle.ImagePaths[href] = outputFilename

		return true
	})

	return readableArticle, nil
}

func fetchReadableHtml(address string) (*ReadableArticle, error) {
	resp, err := http.Get(address)

	if err != nil {
		return nil, err
	}

	log.Info().Str("url", address).Msg("Fetched URL content")

	defer resp.Body.Close()

	parsedUrl, err := url.Parse(address)

	if err != nil {
		return nil, err
	}

	article, err := readability.FromReader(resp.Body, parsedUrl)

	if err != nil {
		return nil, err
	}

	log.Debug().Str("url", address).Msg("successfully applied readability filter to HTML content")

	articleData := &ReadableArticle{
		Title:      article.Title,
		Content:    article.Content,
		ImagePaths: map[string]string{},
	}

	return articleData, nil
}

func fetchImage(imageAddress string, tempDir string) (string, error) {
	parts := strings.Split(imageAddress, "/")
	filename := parts[len(parts)-1]

	imgResp, err := http.Get(imageAddress)

	if err != nil {
		log.Error().Err(err).Str("src", imageAddress).Msg("Failed to fetch image from server")
		return "", err
	}

	defer imgResp.Body.Close()

	outputFile, err := writeFileToTempLocation(imgResp.Body, tempDir, filename)

	if err != nil {
		log.Error().Err(err).Msg("failed to write image to temp location")
		return "", err
	}

	log.Info().Str("src", imageAddress).Str("path", outputFile).Msg("Fetched & wrote image")

	return outputFile, nil
}

func writeFileToTempLocation(reader io.Reader, writePath string, fileName string) (string, error) {
	outputFileName := filepath.Join(writePath, fileName)

	log.Debug().Str("output file name", outputFileName).Msg("Attempting to write file to path")

	file, err := os.Create(outputFileName)

	if err != nil {
		return "", err
	}

	log.Debug().Str("path", outputFileName).Msg("Opened handle to file")

	defer file.Close()

	_, err = io.Copy(file, reader)

	if err != nil {
		return "", err
	}

	log.Debug().Str("path", outputFileName).Msg("Wrote content to file")

	return outputFileName, nil
}
