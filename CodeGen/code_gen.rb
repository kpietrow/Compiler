#!/usr/bin/env ruby

##################################
# Starter function for code gen
#

class UnfinishedError < StandardError
	def initialize (function)
		puts "ERROR: '#{function}' isn't supported yet"
		exit
	end
end



def code_gen

	$code = Code.new
	$static_table = StaticTable.new
	$jump_table = JumpTable.new
	
	generate($ast.root)
	brk
	
	$code.backpatch
	$code.printout
	
	puts "\n==================================================================="
	puts "And here we have our nice payout! Thank you for flying with our 03-K64 Compiler, and I'd like you to know we consider you one of our crew. Have a shiny day!"
	puts "===================================================================\n\n"

	
	puts $code.printout
	
end


##################################
# Handles most of the routing for
# all of the recursive glory
#

def generate (node)

	if node.symbol != nil
		return generate_id(node)
	end
	
	case node.name
	when "block"
		return generate_block(node)
	when "while"
		return generate_while(node)
	when "if"
		return generate_if(node)
	when "declaration"
		return generate_declaration(node)
	when "assign"
		return generate_assignment(node)
	when "print"
		return generate_print(node)
	when "+"
		return generate_add(node)
	when "=="
		return generate_equals(node)
	when "!="
		return generate_notequal(node)
	end
	
	case node.token.type
	when "T_BOOLEAN"
		return generate_boolean(node)
	when "T_DIGIT"
		return generate_digit(node)
	when "T_STRING"
		return generate_string(node)
	end
	

end


######################
# Handles block nodes
#
def generate_block (node)
	puts "Generating a nice block..."
	for child in node.children
		generate(child)
	end
end


######################
# Handles while loops
#
def generate_while (node)

	puts "Generating a nice while loop..."

	
	# Comparison
	address = $code.current_address
	generate(node.children[0])
	entry = $jump_table.add($code.current_address)
	bne(entry.address)
	
	generate(node.children[1])
	
	lda("00")
	sta
	ldx("01")
	cpx
	bne(hex_converter(256 - ($code.current_address - address + 2), 2))
	
	$jump_table.set_last($code.current_address)
	

end


######################
# Handles if nodes
#
def generate_if (node)

	puts "Generating a nice if statement..."


	generate(node.children[0])
	entry = $jump_table.add($code.current_address)
	bne(entry.address)
	generate(node.children[1])
	$jump_table.set_last($code.current_address)

end



######################
# Add symbol to static table
#
def generate_declaration (node)

	puts "Generating a nice declaration..."

		
	entry = $static_table.add(node.children[1].symbol)
	lda("00")
	sta(entry.address)

end


######################
# Assign new value to symbol
#
def generate_assignment (node)

	puts "Generating a nice assignment..."


	# right side
	generate(node.children[1])

	sta($static_table.get(node.children[0].symbol).address)

end


######################
# Generates a string
#
def generate_string (node)

	puts "Generating a nice string..."
	
	# add string to heap
	address = $code.add_string(node.name)
	# load string's address
	lda(hex_converter(address, 2))
end


######################
# Generate a print statement
#
def generate_print (node)
	child = node.children[0]

	# string symbol
	if child.symbol != nil and child.symbol.type == "string"
			puts "Generating a nice print with a string symbol..."

		ldx("02")
		ldy($static_table.get(child.symbol).address)
		sys
	# normal string
	elsif child.token != nil and child.token.type == "T_STRING" and child.symbol == nil
			puts "Generating a nice print with a string..."

		address = $code.add_string(child.name)
		lda(hex_converter(address, 2))
		sta
		ldx("02")
		ldy
		sys
	else
		puts "Generating a nice print with a non-string..."

		generate(child)
		ldx("01")
		sta
		ldy
		sys
		
	end

end


def generate_add (node)

	generate(node.children[1])
	adc(node.children[0].name)
	
end


def generate_equals (node)

	if node.children[0].name == "==" or node.children[1].name == "=="
		raise UnfinishedError.new("nesting =='s")
	elsif node.children[0].name == "!=" or node.children[1].name == "!="
		raise UnfinishedError.new("nesting !='s")
	else
		# left
		generate(node.children[0])
		sta
		ldx
		# right
		generate(node.children[1])
		sta
		cpx
	end

end


def generate_notequal (node)
	raise UnfinishedError.new("!=")
end



def generate_id (node)

	lda($static_table.get(node.symbol).address)

end


def generate_digit (node)

	digit = prepad(Integer(node.name).to_s(16), 2, "0")
	lda(digit)

end


def generate_boolean (node)

	if (node.name == "true")
		lda("01")
		sta
		ldx("01")
		cpx
	else
		lda("00")
		sta
		ldx("01")
		cpx
	end

end






######################
# Add with carry
# 
def adc (input = "FF00")

	if input.length > 2
		$code.add("6D" + input)
	else
		sta
		lda(input)
		adc
	end

end


######################
# Load Accumulator
# If input length is 2, it's a constant
# Else, id
# 
def lda (input = "FF00")

	if input.length > 2
		$code.add("AD" + input)
	else
		
		$code.add("A9" + input)
	end

end


######################
# Store accumulator
#
def sta (input = "FF00")
	$code.add("8D" + input)
end


######################
# Load X register
#
def ldx (input = "FF00")
	
	if input.length > 2
		$code.add("AE" + input)
	else
		$code.add("A2" + input)
	end

end


######################
# Load Y register
#
def ldy (input = "FF00")
	
	if input.length > 2
		$code.add("AC" + input)
	else
		$code.add("A0" + input)
	end

end


######################
# Break/System Call
#
def brk
	$code.add("00")
end


######################
# Compare
#
def cpx (input = "FF00")
	$code.add("EC" + input)
end


######################
# Branch not equal
#
def bne (input = "FF00")
	$code.add("D0" + input)
end


######################
# System call
#
def sys
	$code.add("FF")
end












