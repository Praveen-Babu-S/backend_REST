package main

import (
	"fmt"
	"log"
	"net/http"

	"example.com/microservice/dbcall"
	"example.com/microservice/handlers"
	"example.com/microservice/schema"
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
	// schema.PassCred(*dbCredentials)

	var p *handlers.Product = &handlers.Product{Db: dbcall.GormDb{Db: schema.SetUp()}}
	var r *handlers.Review = &handlers.Review{Db: schema.SetUp()}
	// p.Db=schema.SetUp()
	router := mux.NewRouter()
	//Home Route
	router.HandleFunc("/", homePage).Methods("GET")
	//Produucts page route
	router.HandleFunc("/api/products", p.GetProducts).Methods("GET")
	//Single product route
	router.HandleFunc("/api/products/{id}", p.GetProductById).Methods("GET")
	//reviews page route
	router.HandleFunc("/api/products/{id}/reviews", r.GetReviews).Methods("GET")
	//Add product route
	router.HandleFunc("/api/products/create", p.AddProduct).Methods("POST")
	//add review route
	router.HandleFunc("/api/products/{id}/reviews/create", r.AddReview).Methods("POST")
	//delete product route
	router.HandleFunc("/api/products/{id}/delete", p.DeleteProductById).Methods("DELETE")
	//edit product route
	router.HandleFunc("/api/products/{id}/update", p.UpdateProductById).Methods("PATCH")
	//edit reiew route
	router.HandleFunc("/api/products/reviews/{rid}/update", r.UpdateReviewById).Methods("PATCH")
	log.Fatal(http.ListenAndServe(":4000", router))
}
