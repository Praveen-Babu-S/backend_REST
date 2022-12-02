package models

type Product struct {
	ID       int       `json:"id"`
	Name     string    `json:"name"`
	Desc     string    `json:"desc"`
	Category string    `json:"category"`
	Reviews  []Review  `json:"reviews"`
	Variants []Variant `json:"variants"`
}

type Review struct {
	ID        int    `json:"id"`
	UserName  string `json:"user_name"`
	Desc      string `json:"desc"`
	Rating    uint8  `json:"stars"`
	ProductID int    `json:"product_id"`
}

type Variant struct {
	ID        int    `json:"id"`
	Color     string `json:"color"`
	Image     string `json:"image"`
	ProductID int    `json:"product_id"`
}
