class StripingTag < Liquid::Tag
  def initialize(tag_name, input, tokens)
    super
    @input = input
  end

  def render(context)
  	input_split = split_params(@input)
  	swift = input_split[0].strip
  	c = input_split[1].strip
  	java = input_split[2].strip
  	
    output = "<block class=\"ios inline\"><code> #{swift} </code></block>"
    output += "<block class=\"net inline\"><code> #{c} </code></block>"
    output += "<block class=\"android inline\"><code> #{java} </code></block>"
    return output
  end
  
  def split_params(params)
  	params.split(",")
  end
end

Liquid::Template.register_tag('st', StripingTag)