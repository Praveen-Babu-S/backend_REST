package dbcall

import (
	"example.com/microservice/models"
	"github.com/jinzhu/gorm"
)

type DbOperation interface {
	//product related functions
	FetchProducts() []models.Product
	FetchProductById(int) models.Product
	CreateProduct(models.Product)
	// RemoveProductById(int)
	// UpdateProductById(int, models.Product)
	// //review related functions
	// GetReviewsById(int) []byte
	// AddReview(models.Review)
	// UpdateReviewById(int, models.Review)
}

type GormDb struct {
	Db *gorm.DB
}

func (g GormDb) FetchProducts() []models.Product {
	products := []models.Product{}
	g.Db.Model(&models.Product{}).Preload("Variants").Find(&products)

	return products
}

func (g GormDb) FetchProductById(id int) models.Product {
	var product models.Product
	g.Db.Where(&models.Product{ID: id}).Preload("Variants").Find(&product)
	return product
}

func (g GormDb) CreateProduct(p models.Product) {
	g.Db.Create(&p)
}

func (g GormDb) RemoveProductById(id int) string {
	g.Db.Where(&models.Product{ID: id}).Delete(&models.Product{})
	return "Deleted Product Successfully"
}
func (g GormDb) UpdateProductById(id int, prod models.Product) string {
	g.Db.Model(models.Product{}).Where("id = ?", id).Updates(prod)
	return "Product Updated Successfully!"
}
func (g GormDb) GetReviewById(id int, reviews []models.Review) []models.Review {
	g.Db.Where(&models.Review{ProductID: id}).Find(&reviews)
	return reviews
}

func (g GormDb) AddReview(review models.Review) {
	g.Db.Create(&review)
}

func (g GormDb) UpdateReviewById(id int, review models.Review) {
	g.Db.Model(models.Review{}).Where("id = ?", id).Updates(review)
}

/*



var expected = []models.Product{
	{
		Name:     "IPhone 12",
		Desc:     "128GB ROM 8GB RAM Black Color wireless charging.",
		Category: "Mobiles",
		Reviews: []models.Review{
			{
				UserName: "Rohit",
				Desc:     "This is very nice product.Must go for it.",
				Rating:   4,
			},
			{
				UserName: "Rohit Kumar",
				Desc:     "This is worst Product.",
				Rating:   1,
			},
		},
		Variants: []models.Variant{
			{Color: "Red", Image: "Img1"}, {Color: "Silver", Image: "Img2"},
		},
	},
}
*/
