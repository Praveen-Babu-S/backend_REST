package main

import (
	"fmt"
	"log"
	"net/http"

	"example.com/microservice/routes"
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
	router := mux.NewRouter()
	//Home Route
	router.HandleFunc("/", homePage).Methods("GET")
	//Produucts page route
	router.HandleFunc("/api/products", routes.ProductsPage).Methods("GET")
	//Single product route
	router.HandleFunc("/api/products/{id}", routes.ProductPage).Methods("GET")
	//reviews page route
	router.HandleFunc("/api/products/{id}/reviews", routes.ReviewsPage).Methods("GET")
	//Add product route
	router.HandleFunc("/api/products/create", routes.AddProduct).Methods("POST")
	//add review route
	router.HandleFunc("/api/products/{id}/reviews/create", routes.AddReview).Methods("POST")
	//delete product route
	router.HandleFunc("/api/products/{id}/delete", routes.DeleteProduct).Methods("DELETE")
	//edit product route
	router.HandleFunc("/api/products/{id}/update", routes.UpdateProduct).Methods("PATCH")
	log.Fatal(http.ListenAndServe(":4000", router))
}
