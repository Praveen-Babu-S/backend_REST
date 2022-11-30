package routes

import (
	"encoding/json"
	"io/ioutil"
	"net/http"
	"strconv"

	"example.com/microservice/schema"
	"github.com/gorilla/mux"
)

// update handler
func UpdateProduct(w http.ResponseWriter, r *http.Request) {
	db := schema.SetUp()
	params := mux.Vars(r)
	id, _ := strconv.Atoi(params["id"])
	body, err := ioutil.ReadAll(r.Body)
	if err != nil {
		panic(err)
	}
	var p Product
	err = json.Unmarshal(body, &p)
	if err != nil {
		panic(err)
	}
	// Update with struct
	db.Model(Product{}).Where("id = ?", id).Updates(p)
}
