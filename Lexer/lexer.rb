#!/usr/bin/env ruby

# It's my estimation that  we're gonna be examining incoming input
# here, and translating it with our nice Lexer into some tokens



##
# error for unknown symbols
# exits program, prints line and line number
class UnknownSymbolError < StandardError
	def initialize()
	end
end

# Error for early or nonexistent EOF
class EOFDetectionError < StandardError
	def initialize()
	end
end




def lexer(input)
	# We're gonna run a nice Lexer now
	# Get ourselves some tokens
	
	tokens = []   # Startin' with the input code in a mighty nice array
	c_line = 0    # current line in program
	eof_reached = false   # EOF status
	s_check = false		# for ensuring complete strings
	
	for line in input
		c_string = ""
		c_pos = nil
		
		for i in 0...line.length
		
			# checks for unfinished strings first
			if s_check
			
				# make sure that we're not going to be using nil for tokenize()
				if c_pos == nil
						c_pos = i
				end
			
				# check the different options
				case line[i]
				when /"/
					tokens.push(c_string, "string", c_line, c_pos)
					tokens.push(line[i], "op", c_line, i)
					s_check = false
					break
				when /[ ]/, /[a-z]/
					c_string = c_string + line[i]
				else
					raise UnknownSymbolError, "ERROR: Position: #{i} -> This character here don't belong in no man's string"
					exit
				end
			end	
		
			# test for anything after EOF
			if eof_reached and line[i] =~ /\S/
				raise EOFDetectionError.new(), "ERROR: Position #{i} -> EOF reached early at this location. Will now terminate the program."
				exit
			end
		
			# test here for EOF symbol
			if $eof.match(line[i])
				eof_reached = true
				
				# tokenize current string
				if c_string != ""
					tokens.push(tokenize(c_string, "alphanum", c_line, c_pos))
					
					c_string = ""
					c_pos = nil
				end
				
				# tokenize '$'
				tokens.push(tokenize(line[i], "op", c_line, i))
				
			# Testin' for whitespace
			elsif $space.match(line[i])
				if c_string != ""
					tokens.push(tokenize(c_string, "alphanum", c_line, c_pos))
					
					c_string = ""
					c_pos = nil
				end
			
			# Testin' for operators
			# note: the whitespace issue was handled with the previous elsif
			elsif $operator.match(line[i])
				
				# tokenize c_string if applicable
				if c_string != ""
					tokens.push(tokenize(c_string, "alphanum", c_line, c_pos))
					
					c_string = ""
					c_pos = nil
				end
				
				# attempt to tokenize the operator
				tokens.push(tokenize(line[i], "op", c_line, i))
				
				# if op is ", start the string gathering process
				if /"/.match(line[i])
					s_check = true
				end
				
			# Testin' for alpha numeric characters
			elsif $alpha_numeric.match(line[i])
				# set position of current string
				if c_string == "" and c_pos == nil
					c_pos = i
				end
				
				# add new character to current string
				c_string = c_string + String(line[i])
			
			# else raise error for unknown symbol
			else
				raise UnknownSymbolError.new(), "ERROR: Line Position #{c_pos}, Character \'#{line[i]}\' -> This here character don't appear to be known to no-one around these parts."
				exit
			end
		end
		
		# increment the line number
		c_line = c_line + 1
	end
	
	# if no EOF symbol ($) detected
	if !eof_reached
		begin
			raise EOFDetectionError.new(), "WARNING: No EOF sign ($) reached. Will temporarily add one for this run-through, but the source code will not be altered."
		rescue EOFDetectionError
			tokens.push(tokenize("$", "op", c_line, 0))
		end
	end
	
	# check to make sure that all strings are finished
	if s_check
		raise EOFDetectionError, "ERROR: An unfinished string is present in this here file"
		exit
	end
	
	# return token list
	return tokens
end