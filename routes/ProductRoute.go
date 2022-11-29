package routes

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"
	"strconv"

	"example.com/microservice/schema"
	"github.com/gorilla/mux"
)

// Products Route
func ProductsPage(w http.ResponseWriter, r *http.Request) {
	db := schema.SetUp()
	products := []Product{}
	db.Model(&Product{}).Preload("Variants").Find(&products)
	jsonProducts, err := json.Marshal(&products)
	if err != nil {
		fmt.Fprintf(w, "Something error while fetching!")
	}
	w.Header().Set("Content-Type", "application/json")
	w.Write(jsonProducts)

}

// Route for particular product
func ProductPage(w http.ResponseWriter, r *http.Request) {
	// fmt.Fprintf(w, "This is Product Page\n")
	db := schema.SetUp()
	params := mux.Vars(r)
	id, _ := strconv.Atoi(params["id"])
	var product Product
	db.Where(&Product{ID: id}).Preload("Variants").Find(&product)
	jsonProduct, err := json.Marshal(&product)
	if err != nil {
		fmt.Fprintf(w, "Error in fetching that product")
	}
	w.Header().Set("Content-Type", "application/json")
	w.Write(jsonProduct)

}

func AddProduct(w http.ResponseWriter, req *http.Request) {
	body, err := ioutil.ReadAll(req.Body)
	if err != nil {
		panic(err)
	}
	var t Product
	err = json.Unmarshal(body, &t)
	if err != nil {
		panic(err)
	}
	db := schema.SetUp()
	db.Create(&t)
}

type Product struct {
	ID       int       `json:"id"`
	Name     string    `json:"name"`
	Desc     string    `json:"desc"`
	Category string    `json:"category"`
	Reviews  []Review  `json:"reviews"`
	Variants []Variant `json:"variants"`
}

type Review struct {
	ID        int    `json:"id"`
	UserName  string `json:"user_name"`
	Desc      string `json:"desc"`
	Rating    uint8  `json:"stars"`
	ProductID int    `json:"product_id"`
}

type Variant struct {
	ID        int    `json:"id"`
	Color     string `json:"color"`
	Image     string `json:"image"`
	ProductID int    `json:"product_id"`
}
