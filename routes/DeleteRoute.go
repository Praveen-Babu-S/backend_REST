package routes

import (
	"fmt"
	"net/http"
	"strconv"

	"example.com/microservice/schema"
	"github.com/gorilla/mux"
)

func DeleteProduct(w http.ResponseWriter, r *http.Request) {
	db := schema.SetUp()
	params := mux.Vars(r)
	id, _ := strconv.Atoi(params["id"])
	fmt.Println(id)
	db.Where(&Product{ID: id}).Delete(&Product{})
}
