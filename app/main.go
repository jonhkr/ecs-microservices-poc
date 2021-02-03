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
    "gopkg.in/DataDog/dd-trace-go.v1/ddtrace/tracer"
)

type Message struct {
	From string
	Message string
}

func main() {
	tracer.Start()

    // When the tracer is stopped, it will flush everything it has to the Datadog Agent before quitting.
    // Make sure this line stays in your main function.
    defer tracer.Stop()

	serviceToCall := os.Getenv("SERVICE_TO_CALL")
	serviceName := os.Getenv("SERVICE_NAME")
	port := os.Getenv("PORT")

	http.HandleFunc("/message", func(w http.ResponseWriter, r *http.Request) {
		span := tracer.StartSpan("web.request", tracer.ResourceName("/message"))
	    defer span.Finish()

	    // Set tag
	    span.SetTag("http.url", r.URL.Path)

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