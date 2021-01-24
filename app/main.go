package main

import (
	"net/http"
	"log"
	"time"
	"fmt"
	"io/ioutil"
	"os"
	"encoding/json"
    "math/rand"
)

type Message struct {
	From string
	Message string
}

func main() {
	serviceToCall := os.Getenv("SERVICE_TO_CALL")
	serviceName := os.Getenv("SERVICE_NAME")
	port := os.Getenv("PORT")

	http.HandleFunc("/message", func(w http.ResponseWriter, r *http.Request) {
		m := Message{
			From: serviceName,
			Message: fmt.Sprintf("This is a random int: %d", rand.Intn(100)),
		}
		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(m)
	})

	go ping(serviceToCall)

	log.Fatal(http.ListenAndServe(fmt.Sprintf(":%s", port), nil))
}

func ping(service string) {
	url := fmt.Sprintf("http://%s/message", service)
	for {
		time.Sleep(1 * time.Second)

		resp, err := http.Get(url)

		if err != nil {
			log.Println("request failed: ", err)
			continue
		}

		defer resp.Body.Close()
		body, err := ioutil.ReadAll(resp.Body)

		if err != nil {
			log.Println("failed to read body: ", err)
			continue
		}

		log.Println("Service ", service, " says: ", string(body))
	}
}