package models

type Product struct {
	ID       int       `json:"id,omitempty"`
	Name     string    `json:"name,omitempty"`
	Desc     string    `json:"desc,omitempty"`
	Category string    `json:"category,omitempty"`
	Reviews  []Review  `json:"reviews,omitempty"`
	Variants []Variant `json:"variants,omitempty"`
}

type Review struct {
	ID        int    `json:"id,omitempty"`
	UserName  string `json:"user_name,omitempty"`
	Desc      string `json:"desc,omitempty"`
	Rating    uint8  `json:"stars,omitempty"`
	ProductID int    `json:"product_id,omitempty"`
}

type Variant struct {
	ID        int    `json:"id"`
	Color     string `json:"color"`
	Image     string `json:"image"`
	ProductID int    `json:"product_id"`
}
