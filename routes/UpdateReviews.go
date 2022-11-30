package routes

import (
	"encoding/json"
	"io/ioutil"
	"net/http"
	"strconv"

	"example.com/microservice/schema"
	"github.com/gorilla/mux"
)

func UpdateReviews(w http.ResponseWriter, r *http.Request) {
	db := schema.SetUp()
	params := mux.Vars(r)
	id, _ := strconv.Atoi(params["id"])
	rid, _ := strconv.Atoi(params["rid"])
	body, err := ioutil.ReadAll(r.Body)
	if err != nil {
		panic(err)
	}
	var rew Review
	err = json.Unmarshal(body, &rew)
	if err != nil {
		panic(err)
	}
	rew.ProductID = id
	// Update with struct
	db.Model(Review{}).Where("id = ?", rid).Updates(rew)
}
