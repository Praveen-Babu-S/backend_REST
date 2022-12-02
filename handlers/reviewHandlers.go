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

// Handers for fetching all the reviews for the particular product
func GetReviws(w http.ResponseWriter, r *http.Request) {
	// fmt.Fprintf(w, "This is reviews Page for particular product\n")
	db := schema.SetUp()
	params := mux.Vars(r)
	id, _ := strconv.Atoi(params["id"])
	// fmt.Println(id)
	reviews := []models.Review{}
	db.Where(&models.Review{ProductID: id}).Find(&reviews)
	jsonReviews, _ := json.Marshal(&reviews)
	w.Header().Set("Content-Type", "application/json")
	w.Write(jsonReviews)
}

// Handlers for posting the new review for the given product
func AddReview(w http.ResponseWriter, r *http.Request) {
	db := schema.SetUp()
	params := mux.Vars(r)
	id, _ := strconv.Atoi(params["id"])
	body, err := ioutil.ReadAll(r.Body)
	fmt.Fprintln(w, body)
	if err != nil {
		panic(err)
	}
	var review models.Review
	err = json.Unmarshal(body, &review)
	if err != nil {
		panic(err)
	}
	review.ProductID = id
	db.Create(&review)
	w.Write([]byte("Review Added Successfully!"))
}

// handlers for updating the reviews by the given review id
func UpdateReviewById(w http.ResponseWriter, r *http.Request) {
	db := schema.SetUp()
	params := mux.Vars(r)
	// id, _ := strconv.Atoi(params["id"])
	rid, _ := strconv.Atoi(params["rid"])
	body, err := ioutil.ReadAll(r.Body)
	if err != nil {
		panic(err)
	}
	var rew models.Review
	err = json.Unmarshal(body, &rew)
	if err != nil {
		panic(err)
	}
	// rew.ProductID = id
	// Update with struct
	db.Model(models.Review{}).Where("id = ?", rid).Updates(rew)
	w.Write([]byte("Product Updated Successfully!"))
}
