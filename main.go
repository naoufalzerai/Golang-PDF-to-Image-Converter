package main

import "C"
import (
	"fmt"
	"image/jpeg"
	"io/ioutil"
	"os"
	"path/filepath"

	"github.com/gen2brain/go-fitz"
)

//export PdfToJpeg
func PdfToJpeg(path *C.char) *C.char {

	doc, err := fitz.New(C.GoString(path))
	if err != nil {
		return C.CString(err.Error())
	}

	defer doc.Close()

	tmpDir, err := ioutil.TempDir(os.TempDir(), "fitz")
	if err != nil {
		return C.CString(err.Error())
	}
	// Extract pages as images
	for n := 0; n < doc.NumPage(); n++ {
		img, err := doc.Image(n)
		if err != nil {
			return C.CString(err.Error())
		}

		f, err := os.Create(filepath.Join(tmpDir, fmt.Sprintf("test%03d.jpg", n)))
		if err != nil {
			return C.CString(err.Error())
		}

		err = jpeg.Encode(f, img, &jpeg.Options{jpeg.DefaultQuality})
		if err != nil {
			return C.CString(err.Error())
		}

		f.Close()
	}
	return C.CString(tmpDir)
}

func main() {
}
