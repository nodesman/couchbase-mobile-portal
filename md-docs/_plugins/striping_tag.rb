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
  	
    output = "<block class=\"ios inline\"> #{swift} </block>"
    output += "<block class=\"net inline\"> #{c} </block>"
    output += "<block class=\"android inline\"> #{java} </block>"
    return output
  end
  
  def split_params(params)
  	params.split(",")
  end
end

Liquid::Template.register_tag('st', StripingTag)