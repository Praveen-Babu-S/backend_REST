package main

import (
	"fmt"
	"log"
	"net/http"

	"example.com/microservice/handlers"
	"github.com/gorilla/mux"
)

// Home route
func homePage(w http.ResponseWriter, r *http.Request) {
	fmt.Println()
	fmt.Fprintf(w, "This is home Page\n")

}

func main() {
	// db := schema.App()
	// fmt.Println(db)
	// "postgres", "user=postgres password=root dbname=gorm sslmode=disable"
	// dbCredentials := flag.String("cred", "", "Db Credentials") //receiving db credentails through CLI
	// schema.PassCred(*dbCredentials)                            //passing db credentials
	router := mux.NewRouter()
	//Home Route
	router.HandleFunc("/", homePage).Methods("GET")
	//Produucts page route
	router.HandleFunc("/api/products", handlers.GetProducts).Methods("GET")
	//Single product route
	router.HandleFunc("/api/products/{id}", handlers.GetProductById).Methods("GET")
	//reviews page route
	router.HandleFunc("/api/products/{id}/reviews", handlers.GetReviws).Methods("GET")
	//Add product route
	router.HandleFunc("/api/products/create", handlers.AddProduct).Methods("POST")
	//add review route
	router.HandleFunc("/api/products/{id}/reviews/create", handlers.AddReview).Methods("POST")
	//delete product route
	router.HandleFunc("/api/products/{id}/delete", handlers.DeleteProductById).Methods("DELETE")
	//edit product route
	router.HandleFunc("/api/products/{id}/update", handlers.UpdateProductById).Methods("PATCH")
	//edit reiew route
	router.HandleFunc("/api/products/reviews/{rid}/update", handlers.UpdateReviewById).Methods("PATCH")
	log.Fatal(http.ListenAndServe(":4000", router))
}
