package handlers

import (
	"encoding/json"
	"fmt"
	"net/http"
	"net/http/httptest"
	"reflect"
	"strconv"
	"testing"

	"example.com/microservice/dbcall"
	models "example.com/microservice/models"
	"github.com/golang/mock/gomock"
	"github.com/gorilla/mux"
	"github.com/stretchr/testify/assert"
)

var expected1 = []models.Product{
	{
		ID:       1,
		Name:     "IPhone 12",
		Desc:     "128GB ROM 8GB RAM Black Color wireless charging.",
		Category: "Mobiles",
		Variants: []models.Variant{
			{ID: 1, Color: "Red", Image: "Img1", ProductID: 1}, {ID: 2, Color: "Silver", Image: "Img2", ProductID: 1},
		},
	},
}

func TestGetProducts(t *testing.T) {
	req, err := http.NewRequest("GET", "/api/products", nil)
	if err != nil {
		t.Fatal(err)
	}
	controller := gomock.NewController(t)
	defer controller.Finish()

	MockDb := dbcall.NewMockDbOperation(controller)
	var p = Product{Db: MockDb}
	MockDb.EXPECT().FetchProducts().Return(expected1)

	rr := httptest.NewRecorder()
	handler := http.HandlerFunc(p.GetProducts)
	handler.ServeHTTP(rr, req)

	var got []models.Product
	_ = json.Unmarshal(rr.Body.Bytes(), &got)
	// decoder := json.NewDecoder(rr.Body)
	// err = decoder.Decode(&got)
	// !reflect.DeepEqual(expected1, got)
	// if expected1 != got {
	// 	t.Errorf("Test Case failed: got %v want %v",
	// 		got, expected1)
	// }
	assert.Equal(t, got, expected1)
	// fmt.Println(got)
	// fmt.Println(expected1)

}

func TestGetProduct(t *testing.T) {
	expected2 := models.Product{
		ID:       1,
		Name:     "IPhone 12",
		Desc:     "128GB ROM 8GB RAM Black Color wireless charging.",
		Category: "Mobiles",
		Variants: []models.Variant{
			{ID: 1, Color: "Red", Image: "Img1", ProductID: 1}, {ID: 2, Color: "Silver", Image: "Img2", ProductID: 1},
		},
	}

	req, err := http.NewRequest("GET", "/api/products/{id}", nil)
	if err != nil {
		t.Fatal(err)
	}
	//Hack to try to fake gorilla/mux vars
	vars := map[string]string{
		"id": "1",
	}

	// CHANGE THIS LINE!!!
	req = mux.SetURLVars(req, vars)
	controller := gomock.NewController(t)
	defer controller.Finish()

	MockDb := dbcall.NewMockDbOperation(controller)
	var p = Product{Db: MockDb}
	params := mux.Vars(req)
	id, e := strconv.Atoi(params["id"])
	if e != nil {
		panic(e.Error())
	}
	MockDb.EXPECT().FetchProductById(id).Return(expected2)

	rr := httptest.NewRecorder()
	handler := http.HandlerFunc(p.GetProductById)
	handler.ServeHTTP(rr, req)

	var actual models.Product
	// fmt.Println(rr.Body.Bytes())
	// err = json.Unmarshal(rr.Body.Bytes(), &actual)
	// if err != nil {
	// 	panic(err.Error())
	// }
	// fmt.Println("1")
	// fmt.Println(rr.Body.String())
	decoder := json.NewDecoder(rr.Body)
	err = decoder.Decode(&actual)
	if err != nil {
		panic(err.Error())
	}
	// fmt.Println("2")
	if !reflect.DeepEqual(expected2, actual) {
		t.Errorf("Test Case failed: got %v want %v",
			actual, expected1)
	}
	fmt.Println("Expected", expected2)
	fmt.Println("Got", actual)
	// assert.Equal(t, actual, expected2)
}

//unit test for testing createproduct route
// expected output is : {"err":nil,"msg":"Product Added Successfully!"}

func TestAddProduct(t *testing.T) {
	expectedmsg := `{"err":nil,"msg":"Product Added Successfully!"}`
	product_add := models.Product{
		ID:       3,
		Name:     "Product",
		Desc:     "Desc",
		Category: "Mobiles",
	}
	req, err := http.NewRequest("POST", "/api/products/create", nil)
	if err != nil {
		t.Fatal(err)
	}
	controller := gomock.NewController(t)
	defer controller.Finish()

	MockDb := dbcall.NewMockDbOperation(controller)
	var p = Product{Db: MockDb}
	MockDb.EXPECT().CreateProduct(product_add).Return(expectedmsg)

	rr := httptest.NewRecorder()
	handler := http.HandlerFunc(p.GetProducts)
	handler.ServeHTTP(rr, req)
	decoder := json.NewDecoder(rr.Body)
	var actual string
	err = decoder.Decode(&actual)
	if err != nil {
		panic(err.Error())
	}
	if err != nil {
		panic(err.Error())
	}
	// fmt.Println("2")
	if !reflect.DeepEqual(expectedmsg, actual) {
		t.Errorf("Test Case failed: got %v want %v",
			actual, expected1)
	}

}
