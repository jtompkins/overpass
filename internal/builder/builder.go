package builder

import (
	"os"
	"overpass/internal/fetcher"
	"strings"

	"github.com/PuerkitoBio/goquery"
	"github.com/go-shiori/go-epub"
	"github.com/rs/zerolog/log"
)

func BuildEbook(urls []string) error {
	tempDir, err := os.MkdirTemp("", "epubbuilder")

	if err != nil {
		return err
	}

	log.Debug().Str("temp dir", tempDir).Msg("Generated temp directory")

	defer os.RemoveAll(tempDir)

	outputEpub, err := epub.NewEpub("Output EPUB")

	if err != nil {
		return err
	}

	log.Debug().Msg("Created handle to ePub")

	for _, url := range urls {
		article, err := fetcher.FetchArticle(url, tempDir)

		if err != nil {
			return err
		}

		log.Info().Str("url", url).Str("article", article.String()).Msg("fetched article")

		if _, err = addArticleToEPub(article, outputEpub); err != nil {
			return err
		}

		log.Debug().Msg("successfully added article to ePub")
	}

	outputEpub.EmbedImages()
	err = outputEpub.Write("output.epub")

	if err != nil {
		return err
	}

	log.Info().Msg("Wrote ePub to disk")

	return nil
}

func addArticleToEPub(article *fetcher.ReadableArticle, outputEpub *epub.Epub) (bool, error) {
	// add images to epub, map epub HTML to new images
	doc, err := goquery.NewDocumentFromReader(strings.NewReader(article.Content))

	if err != nil {
		return false, err
	}

	doc.Find("img").EachWithBreak(func(i int, s *goquery.Selection) bool {
		href, exists := s.Attr("src")

		if !exists {
			return false
		}

		epubImagePath, err := outputEpub.AddImage(article.ImagePaths[href], "")

		if err != nil {
			return false
		}

		s.SetAttr("src", epubImagePath)

		return true
	})

	readableHtml, err := doc.Html()

	if err != nil {
		return false, err
	}

	_, err = outputEpub.AddSection(readableHtml, article.Title, "", "")

	if err != nil {
		return false, err
	}

	return true, nil
}
