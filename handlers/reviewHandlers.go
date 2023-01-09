package handlers

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"
	"strconv"

	"example.com/microservice/dbcall"
	models "example.com/microservice/models"
	"github.com/gorilla/mux"
	"github.com/jinzhu/gorm"
)

type ReviewsServices interface {
	GetReviws(http.ResponseWriter, *http.Request)
	AddReview(http.ResponseWriter, *http.Request)
	UpdateReviewById(http.ResponseWriter, *http.Request)
}

type Review struct {
	Db *gorm.DB
}

// Handers for fetching all the reviews for the particular product
func (r *Review) GetReviews(w http.ResponseWriter, req *http.Request) {
	// fmt.Fprintf(w, "This is reviews Page for particular product\n")
	db := r.Db
	params := mux.Vars(req)
	id, _ := strconv.Atoi(params["id"])
	// fmt.Println(id)
	reviews := []models.Review{}
	// db.Where(&models.Review{ProductID: id}).Find(&reviews)
	reviews = dbcall.GormDb{Db: db}.GetReviewById(id, reviews)
	jsonReviews, _ := json.Marshal(&reviews)
	w.Header().Set("Content-Type", "application/json")
	w.Write(jsonReviews)
}

// Handlers for posting the new review for the given product
func (r *Review) AddReview(w http.ResponseWriter, req *http.Request) {
	db := r.Db
	params := mux.Vars(req)
	id, _ := strconv.Atoi(params["id"])
	body, err := ioutil.ReadAll(req.Body)
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
	// db.Create(&review)
	dbcall.GormDb{Db: db}.AddReview(review)
	w.Write([]byte("Review Added Successfully!"))
}

// handlers for updating the reviews by the given review id
func (r *Review) UpdateReviewById(w http.ResponseWriter, req *http.Request) {
	db := r.Db
	params := mux.Vars(req)
	// id, _ := strconv.Atoi(params["id"])
	rid, _ := strconv.Atoi(params["rid"])
	body, err := ioutil.ReadAll(req.Body)
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
	// db.Model(models.Review{}).Where("id = ?", rid).Updates(rew)
	dbcall.GormDb{Db: db}.UpdateReviewById(rid, rew)
	w.Write([]byte("Product Updated Successfully!"))
}
