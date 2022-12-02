package handlers

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"
	"strconv"

	models "example.com/microservice/models"
	"example.com/microservice/schema"
	"github.com/gorilla/mux"
)

// Handlers for fetching all the products
func GetProducts(w http.ResponseWriter, r *http.Request) {
	db := schema.SetUp()
	products := []models.Product{}
	db.Model(&models.Product{}).Preload("Variants").Find(&products)
	jsonProducts, err := json.Marshal(&products)
	if err != nil {
		fmt.Fprintf(w, "Something error while fetching!")
	}
	w.Header().Set("Content-Type", "application/json")
	w.Write(jsonProducts)

}

// Handlers for fetching particular product
func GetProductById(w http.ResponseWriter, r *http.Request) {
	// fmt.Fprintf(w, "This is Product Page\n")
	db := schema.SetUp()
	params := mux.Vars(r)
	id, _ := strconv.Atoi(params["id"])
	var product models.Product
	db.Where(&models.Product{ID: id}).Preload("Variants").Find(&product)
	jsonProduct, err := json.Marshal(&product)
	if err != nil {
		fmt.Fprintf(w, "Error in fetching that product")
	}
	w.Header().Set("Content-Type", "application/json")
	w.Write(jsonProduct)

}

// handlers for adding the new products
func AddProduct(w http.ResponseWriter, req *http.Request) {
	body, err := ioutil.ReadAll(req.Body)
	if err != nil {
		panic(err)
	}
	var t models.Product
	err = json.Unmarshal(body, &t)
	if err != nil {
		w.Write([]byte(err.Error()))
		panic(err)
	}
	db := schema.SetUp()
	db.Create(&t)
	// msg := "Product Added Successfully!"
	// w.Header().Set("Content-Type", "application/json")
	w.Write([]byte("Product Added Successfully!"))
}

// handlers for deleting the given product with id
func DeleteProductById(w http.ResponseWriter, r *http.Request) {
	db := schema.SetUp()
	params := mux.Vars(r)
	id, _ := strconv.Atoi(params["id"])
	// fmt.Println(id)
	db.Where(&models.Product{ID: id}).Delete(&models.Product{})
	w.Write([]byte("Deleted product Successfully!"))
}

// handlers for updating the given product
func UpdateProductById(w http.ResponseWriter, r *http.Request) {
	db := schema.SetUp()
	params := mux.Vars(r)
	id, _ := strconv.Atoi(params["id"])
	body, err := ioutil.ReadAll(r.Body)
	if err != nil {
		panic(err)
	}
	var p models.Product
	err = json.Unmarshal(body, &p)
	if err != nil {
		panic(err)
	}
	// Update with struct
	db.Model(models.Product{}).Where("id = ?", id).Updates(p)
	w.Write([]byte("Product Updated Successfully!"))
}

// type Product struct {
// 	ID       int       `json:"id"`
// 	Name     string    `json:"name"`
// 	Desc     string    `json:"desc"`
// 	Category string    `json:"category"`
// 	Reviews  []Review  `json:"reviews"`
// 	Variants []Variant `json:"variants"`
// }

// type Review struct {
// 	ID        int    `json:"id"`
// 	UserName  string `json:"user_name"`
// 	Desc      string `json:"desc"`
// 	Rating    uint8  `json:"stars"`
// 	ProductID int    `json:"product_id"`
// }

// type Variant struct {
// 	ID        int    `json:"id"`
// 	Color     string `json:"color"`
// 	Image     string `json:"image"`
// 	ProductID int    `json:"product_id"`
// }
