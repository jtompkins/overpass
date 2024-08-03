package fetcher

import "encoding/json"

type ReadableArticle struct {
	Title      string
	Content    string
	ImagePaths map[string]string
}

func (a ReadableArticle) String() string {
	out, err := json.Marshal(a)

	if err != nil {
		panic(err)
	}

	return string(out)
}
