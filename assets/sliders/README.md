# Slider images

Slider images run across the top of many pages of the site. They are 450px high and wider than any screen resolution, say 1400px+. When the page has multiple slides, the banner/slider will slide across to reveal more of the scene.

## Credits for images

* [sky-horizon](http://www.goodfon.com/wallpaper/59136.html) images
* [sheep](http://blog.ecoagriculture.org/2012/05/04/es_cap/)

## To add sliders

* Find a nice image that is 1400px+ and store it in `assets/sliders/original` folder.
* Crop it to 450px high and store it in this `articles/sliders` folder.
* In `parallax-slider.css`, add a CSS class as below, replacing NAME with a useful name.

``` css
.da-slider-NAME{
  background: transparent url(/assets/sliders/NAME.png) repeat 0% 0% !important;
}
```

The slider can now be used in posts and pages with a YAML header such as:

``` yaml
---
layout: post
sliders:
- title: "The slide title"
  text: The slide text
slider_background: NAME
theme:
  name: smart-business-template
...
---
...
```

