package handlers

import (
	"encoding/json"
	"fmt"
	"io"
	"io/ioutil"
	"net/http"
	"strconv"

	"example.com/microservice/dbcall"
	models "example.com/microservice/models"
	"github.com/gorilla/mux"
)

type ProductServices interface {
	GetProducts(w http.ResponseWriter, r *http.Request)
	GetProductById(w http.ResponseWriter, r *http.Request)
	AddProduct(w http.ResponseWriter, req *http.Request)
	UpdateProductById(w http.ResponseWriter, r *http.Request)
}

type Product struct {
	Db dbcall.DbOperation
}

// Handlers for fetching all the products
func (p Product) GetProducts(w http.ResponseWriter, r *http.Request) {
	// db := p.Db
	products := []models.Product{}
	// db.Model(&models.Product{}).Preload("Variants").Find(&products)
	products = p.Db.FetchProducts()
	jsonProducts, err := json.Marshal(&products)
	if err != nil {
		panic(err.Error())
	}
	w.Header().Set("Content-Type", "application/json")
	// w.Write(jsonProducts)
	io.WriteString(w, string(jsonProducts))
}

// Handlers for fetching particular product
func (p Product) GetProductById(w http.ResponseWriter, r *http.Request) {
	// db := p.Db
	params := mux.Vars(r)
	id, _ := strconv.Atoi(params["id"])
	// db.Where(&models.Product{ID: id}).Preload("Variants").Find(&product)
	product := p.Db.FetchProductById(id)
	jsonProduct, err := json.Marshal(&product)
	if err != nil {
		fmt.Fprintf(w, "Error in fetching that product")
	}
	w.Header().Set("Content-Type", "application/json")
	fmt.Println("TEST", string(jsonProduct))
	w.Write(jsonProduct)
}

// handlers for adding the new products
func (p Product) AddProduct(w http.ResponseWriter, req *http.Request) {
	body, err := ioutil.ReadAll(req.Body)
	if err != nil {
		panic(err)
	}
	var t models.Product
	err = json.Unmarshal(body, &t)
	if err != nil {
		io.WriteString(w, string([]byte(err.Error())))
		panic(err)
	}
	// db := p.Db
	// db.Create(&t)
	p.Db.CreateProduct(t)
	fmt.Println("Method Called")
	w.Header().Set("Content-Type", "application/json")
	io.WriteString(w, `{"err":nil,"msg":"Product Created Successfully!"}`)
}

// handlers for deleting the given product with id
func (p Product) DeleteProductById(w http.ResponseWriter, r *http.Request) {
	// // db := p.Db
	// params := mux.Vars(r)
	// id, _ := strconv.Atoi(params["id"])
	// // fmt.Println(id)
	// // db.Where(&models.Product{ID: id}).Delete(&models.Product{})
	// p.Db.RemoveProductById(id)
	// w.Header().Set("Content-Type", "application/json")
	// io.WriteString(w, `{"err":nil,"msg":"Product deleted Successfully!"}`)
}

// handlers for updating the given product
func (p Product) UpdateProductById(w http.ResponseWriter, r *http.Request) {
	// // db := p.Db
	// params := mux.Vars(r)
	// id, _ := strconv.Atoi(params["id"])
	// body, err := ioutil.ReadAll(r.Body)
	// if err != nil {
	// 	io.WriteString(w, string([]byte(err.Error())))
	// 	panic(err)
	// }
	// var prod models.Product
	// err = json.Unmarshal(body, &prod)
	// if err != nil {
	// 	io.WriteString(w, string([]byte(err.Error())))
	// 	panic(err)
	// }
	// // Update with struct
	// // db.Model(models.Product{}).Where("id = ?", id).Updates(prod)
	// p.Db.UpdateProductById(id, prod)
	// w.Header().Set("Content-Type", "application/json")
	// io.WriteString(w, `{"err":nil,"msg":"Product updated Successfully!"}`)
}
