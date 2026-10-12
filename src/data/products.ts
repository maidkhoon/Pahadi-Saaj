export type Category = 'Ladies’ Suits' | 'Sadriyaan';
export interface Product { id: string; name: string; category: Category; description: string; priceLabel: string; image: string; imageAlt: string; colour: string; note: string; }

// Public Unsplash photos used as illustrative catalogue imagery, not verified shop stock.
const photos = {
 cream: 'https://images.unsplash.com/photo-1743229995505-d6374996df1c?auto=format&fit=crop&w=900&q=85',
 floral: 'https://images.unsplash.com/photo-1743229995753-69be4b438204?auto=format&fit=crop&w=900&q=85',
 green: 'https://images.unsplash.com/photo-1756483510767-35245638c057?auto=format&fit=crop&w=900&q=85',
 turquoise: 'https://images.unsplash.com/photo-1756483527936-ba6524729fbe?auto=format&fit=crop&w=900&q=85',
 sadri: 'https://images.unsplash.com/photo-1756483510767-35245638c057?auto=format&fit=crop&w=900&q=85'
};
export const products: Product[] = [
 {id:'suit-01',name:'Everyday Elegance Suit',category:'Ladies’ Suits',description:'Traditional Indian attire with detailed embroidery.',priceLabel:'Price on enquiry',image:photos.cream,imageAlt:'Model wearing turquoise traditional Indian embroidered attire',colour:'Turquoise',note:'Illustrative image'},
 {id:'suit-02',name:'Classic Floral Suit',category:'Ladies’ Suits',description:'A floral-inspired traditional outfit for a graceful look.',priceLabel:'Price on enquiry',image:photos.floral,imageAlt:'Model wearing a floral Indian suit with dupatta',colour:'Floral',note:'Illustrative image'},
 {id:'suit-03',name:'Festive Thread Suit',category:'Ladies’ Suits',description:'An embroidered traditional outfit in a rich colour palette.',priceLabel:'Price on enquiry',image:photos.green,imageAlt:'Model wearing a green embroidered traditional Indian outfit',colour:'Green',note:'Illustrative image'},
 {id:'suit-04',name:'Soft Bloom Suit',category:'Ladies’ Suits',description:'A bright traditional look for festive occasions.',priceLabel:'Price on enquiry',image:photos.turquoise,imageAlt:'Model wearing turquoise Indian attire with gold embroidery',colour:'Turquoise',note:'Illustrative image'},
 {id:'sadri-01',name:'Traditional Sadri',category:'Sadriyaan',description:'A traditional Indian outfit reference for the menswear collection.',priceLabel:'Price on enquiry',image:photos.sadri,imageAlt:'Traditional Indian clothing inspiration; not a verified product photo',colour:'Traditional',note:'Illustrative image'},
 {id:'sadri-02',name:'Classic Woven Sadri',category:'Sadriyaan',description:'A catalogue inspiration image pending shop stock photography.',priceLabel:'Price on enquiry',image:photos.sadri,imageAlt:'Traditional Indian clothing inspiration; not a verified product photo',colour:'Heritage',note:'Illustrative image'},
 {id:'sadri-03',name:'Festive Heritage Sadri',category:'Sadriyaan',description:'A festive traditional-wear inspiration image.',priceLabel:'Price on enquiry',image:photos.sadri,imageAlt:'Traditional Indian clothing inspiration; not a verified product photo',colour:'Festive',note:'Illustrative image'},
 {id:'sadri-04',name:'Everyday Sadri',category:'Sadriyaan',description:'A traditional style reference pending actual product photos.',priceLabel:'Price on enquiry',image:photos.sadri,imageAlt:'Traditional Indian clothing inspiration; not a verified product photo',colour:'Classic',note:'Illustrative image'}
];
