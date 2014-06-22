---
layout: post
title: "Simple Skin Detection in JavaScript"
permalink: /posts/skin-detection/
summary: Skin detection is simple but complex task, this post explores the possibility of writing a skin detector in javascript, using the canvas api in html5 and considering the color model.
parent: blog
---

Skin detection is a very interesting technique with a vivid use case possibility from writing automated
nudity detection scripts to brilliant photographic filters to enhance photographs. Historically it has been
a topic of interests and hence has a lot of work done earlier on the topic. This quick and ugly skin detector using 
canvas ([demo](http://codepen.io/darkyen/pen/ubBHt)) was implemented in hurry almost an year ago sitting in the back 
of a JAVA tutorial in college (which i was not so interested in). It uses a basic hypothesis that skin pixels are very
closely present in a specific region inside the HSL Colorspace.

> Please note that this is the most simple and primitive method for skin detection, better methods exist and must be chosen

###HSL Colorspace
--
In computers everything is supposed to be a number and hence there are multiple ways to represent a color in a computer,
the most used model being RGB which defines a color as parts of Red, Green and Blue primary colors which can be mixed to obtain
over Sixteen Million Colors. In real world colors are not RGB but instead we percieve colors with a hue its intensity and its brightness
in 1980s computer scientists proposed this new color model which is more logical for humans. The HSL color space defines colors more naturally: Hue specifies the base color, the other two values then let you specify the saturation of that color and how bright the color should be (there exists HSV its close cousin). It is obvious that being close to natural phenomenon this allows us to have more control
and gives a well defined region for skin color (contrary to the RGB colorspace where colors are scattered throughout the spectrum). But computers represent images as RGB Still and so does canvas. Hence we first extract the color values and then convert it to our chosen color-space. This can be simply done using simple mathematics (which turns down to somewhat ugly programming)

{% highlight javascript %}


ImageProcessor.toHSV = function () {

    if (this.mode === undefined) {
    	// Fail proofing
        console.log("Invalid call");
        return;
    }
    
    if (this.mode === ImageProcessor.color_modes.HSV) {
    	// Safety check
        return;
    }

    // Delcare the temporary variables
    var w = this.width,
        ht = this.height,
        x = 0,
        y = 0,
        h, s, v,max,min,delta,r,g,b,
        pixel = null;

    // Set our buffers color model to HSL
    this.mode = ImageProcessor.color_modes.HSL;


    for (y; y < ht; y++) {
        for (x = 0; x < w; x++) {
    		// For every pixel 
            pixel = this.data[y][x];
            
            // Find the relative & normalized RGB values
            r = pixel.R / 255;
            g = pixel.G / 255;
            b = pixel.B / 255;

            // Then find the ma and min of R & G & B in them
            max = Math.max(r,g,b);
            min = Math.min(r,g,b);

            // Find the range
            delta = max-min;

            //find the S and l

            // found this formula on wikipedia
            v = max;
            if( max !== 0 && delta !== 0){
                s = delta/max;

                if( r === max)
                    h = ((g-b)/delta) % 6;
                else if( g === max )
	    	        h = 2 + (( b - r ) / delta);
	            else
		            h = 4 + (( r - g ) / delta);
	            
                h *= 60;
	            if( h < 0 )
		            h += 360;
            }else{
                h = 0;
                s = 0;
            }
            
            // set HSV as RGB triplets
            // Ugly code ... must update !
            pixel.R = h;
            pixel.G = s;
            pixel.B = v;
        }
    }
}
{% endhighlight %}


Once we have obtained the HSV values for image, we simply threshold the image for the region we wish
this results in a black and white image because all the pixels not meeting the skin region are turned off
the code performing this is rather simple and hence not discussed.


###Erode and Dilute
--
Erode and Dilute are two image processing filters, in simple terms erode is a filter which reduces the area
painted in an image. For example imagine a block of 3x3 which is filled with colors upon a pass of erode 
only the pixel whose all surrounding pixels are ON will stay ON rest all the pixels with either of neighbouring
pixel turned OFF will be turned off. Thus erode effectively reduces the region painted. Dilute is the exact opposite
of erode it is used to effectively increase the area painted. By using Erode and Dilute in conjunction we edge off the noise.
The first pass of erode will remove the small noise present and thus only leaving the bigger blobs of detected region ON followed
by the Dilute filter which expands this left area.

{% highlight javascript %}

	// Load the image 
	ip2.loadImage(albert);

	// Extract pixel data out of it
    mm = ip2.getMap();

    // Convert it to HSV
    ImageProcessor.toHSV.call(mm);
    mm.mode = ImageProcessor.color_modes.RGBA;
    
    // Call threshold
    ImageProcessor.ThresHold.call(mm,{
        R:38,
        G:0.68
    },{
        R:6,
        G:0.23
    });

    // Erode 2 pixels
    ImageProcessor.Erode.call(mm,2);
    // Dilute 3 pixels        
    ImageProcessor.Dilute.call(mm,3);

    // Repaint the generated area
    ip2.setMap(mm);
    ip2.render();

    // Draw the original image only above the detected region
    ip2.compositePaintImage(albert,'source-in');
{% endhighlight %}

###Limitations

Though this technique just works but there are huge limitations to it.

* Various Skin Colors Need Different hard coding
* Color is not a right measure, skin colored walls can confuse the algorithm

