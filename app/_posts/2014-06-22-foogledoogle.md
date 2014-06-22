---
layout: post
title: "foogledoogle"
summary: foogle is doogle is foogly doogle for foogle doogle foogle foogle
---

sdfsfd

{% highlight ruby %}
def show
  @widget = Widget(params[:id])
  respond_to do |format|
    format.html # show.html.erb
    format.json { render json: @widget }
  end
end
{% endhighlight %}