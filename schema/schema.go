package schema

import (
	"fmt"

	"github.com/jinzhu/gorm"
	_ "github.com/lib/pq"
)

// setting up connection to database
func SetUp() *gorm.DB {
	var db, err = gorm.Open("postgres", "user=postgres password=root dbname=gorm sslmode=disable")
	if err != nil {
		fmt.Println(err.Error())
	}
	// defer db.Close()
	return db
}
func App() *gorm.DB {
	db := SetUp()
	//creating table for Products
	db.DropTable(&Product{})
	db.CreateTable(&Product{})

	//creating table for Reviews
	db.DropTable(&Review{})
	db.CreateTable(&Review{})

	//creating table for variants
	db.DropTable(&Variant{})
	db.CreateTable(&Variant{})
	//setting foreign key for reviews table
	db.Debug().Model(&Review{}).AddForeignKey("product_id", "products(id)", "CASCADE", "CASCADE")
	//setting foreign key for variants table
	db.Debug().Model(&Variant{}).AddForeignKey("product_id", "products(id)", "CASCADE", "CASCADE")
	p := Product{
		Name:     "IPhone 12",
		Desc:     "128GB ROM 8GB RAM Black Color wireless charging.",
		Category: "Mobiles",
		Reviews: []Review{
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
		Variants: []Variant{
			{Color: "Red", Image: "Img1"}, {Color: "Silver", Image: "Img2"},
		},
	}
	db.Create(&p)

	fmt.Println("Working!")
	return db
}

type Product struct {
	ID       int
	Name     string
	Desc     string
	Category string
	Reviews  []Review
	Variants []Variant
}

type Review struct {
	ID        int
	UserName  string
	Desc      string
	Rating    uint8
	ProductID int
}

type Variant struct {
	ID        int
	Color     string
	Image     string
	ProductID int
}
