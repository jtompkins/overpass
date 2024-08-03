package main

import (
	"os"
	"overpass/internal/builder"

	"github.com/rs/zerolog"
	"github.com/rs/zerolog/log"
)

func main() {
	zerolog.TimeFieldFormat = zerolog.TimeFormatUnix
	log.Logger = log.Output(zerolog.ConsoleWriter{Out: os.Stdout})

	targets := []string{
		"https://magic.wizards.com/en/news/feature/planeswalkers-guide-to-bloomburrow-part-1",
		"https://magic.wizards.com/en/news/feature/planeswalkers-guide-to-bloomburrow-part-2",
		"https://magic.wizards.com/en/news/feature/planeswalkers-guide-to-bloomburrow-part-3",
	}

	log.Info().Int("targets", len(targets)).Msg("Starting ePub build")

	err := builder.BuildEbook(targets)

	if err != nil {
		log.Fatal().Err(err)
	}
}
