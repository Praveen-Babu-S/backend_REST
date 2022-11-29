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

// Route for reviews
func ReviewsPage(w http.ResponseWriter, r *http.Request) {
	// fmt.Fprintf(w, "This is reviews Page for particular product\n")
	db := schema.SetUp()
	params := mux.Vars(r)
	id, _ := strconv.Atoi(params["id"])
	fmt.Println(id)
	reviews := []Review{}
	db.Where(&Review{ProductID: id}).Find(&reviews)
	jsonReviews, _ := json.Marshal(&reviews)
	w.Header().Set("Content-Type", "application/json")
	w.Write(jsonReviews)
}

// Add Review Route
func AddReview(w http.ResponseWriter, r *http.Request) {
	db := schema.SetUp()
	params := mux.Vars(r)
	id, _ := strconv.Atoi(params["id"])
	body, err := ioutil.ReadAll(r.Body)
	fmt.Fprintln(w, body)
	if err != nil {
		panic(err)
	}
	var review Review
	err = json.Unmarshal(body, &review)
	if err != nil {
		panic(err)
	}
	review.ProductID = id
	db.Create(&review)
}
