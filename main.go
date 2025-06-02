package main

import (
	"fmt"
	"net/http"
	"os"
)

var version = "unknown"

func handler(w http.ResponseWriter, r *http.Request) {
	hostname, _ := os.Hostname()
	ip := r.RemoteAddr

	fmt.Fprintf(w, "<h1>Informacje o serwerze</h1>")
	fmt.Fprintf(w, "Adres IP: %s<br>", ip)
	fmt.Fprintf(w, "Hostname: %s<br>", hostname)
	fmt.Fprintf(w, "Wersja aplikacji: %s<br>", version)
}

func main() {
	http.HandleFunc("/", handler)
	http.ListenAndServe(":8080", nil)
}
