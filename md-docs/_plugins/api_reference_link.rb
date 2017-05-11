class APIReferenceTag < Liquid::Tag
  def initialize(tag_name, input, tokens)
    super
    @input = input
  end

  def render(context)
    references = context.registers[:site].config['references']
    params_split = split_params(@input)
  	swift = split_param(params_split[0].strip)
  	# objc = input_split[1].strip
  	# c = input_split[2].strip
  	# java = input_split[3].strip
  	
    output = "<block class=\"swift inline\"><a style=\"font-family: Courier New,Courier,monospace,sans-serif;text-decoration: none;\" href=\"#{references['swift']}#{swift[1].strip}\">#{swift[0].strip}</a></block>"
   #  output += "<block class=\"objc inline\"><code> #{objc}</code></block>"
   #  output += "<block class=\"net inline\"><code> #{c}</code></block>"
   #  output += "<block class=\"java inline\"><code> #{java}</code></block>"
   return output
  end

  def split_param(param)
    param.split(',')
  end
  
  def split_params(params)
  	params.split("|")
  end
end

Liquid::Template.register_tag('ref', APIReferenceTag)