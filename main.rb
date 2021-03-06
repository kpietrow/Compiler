#!/usr/bin/env ruby


###################################################
# This is the cockpit of the 03-K64 Compiler.
# Crafted for Alan's 'Design Compilers' class,
# lovingly coded in Ruby magic, and narrated by
# her captain.
#
#
# Author: Kevin Pietrow
# Version: The shinier one
# 
# Note: Instructions for running the best compiler
# 		in the Verse can be found in the README
#



# Get all of our requireds
require './Lexer/lexer.rb'
require './Lexer/tokenizer.rb'
require './Parser/parser.rb'
require './SymbolTable/symbol_table.rb'
require './SemanticAnalysis/semantic_analysis.rb'
require './SyntaxTrees/cst.rb'
require './SyntaxTrees/ast.rb'
require './SyntaxTrees/node.rb'
require './SyntaxTrees/cst_converter.rb'
require './CodeGen/code_gen.rb'
require './CodeGen/code_gen_helpers.rb'

# Error for a blank file of input
class BlankFileError < StandardError
	def initialize
		puts "ERROR: There don't seem to be any information in that here file. We're just gonna exit the program for ye."
		exit
	end
end


##
# Settin' up global regex variables now
#
$digit = /[0-9]/
$character = /[a-z]/
$space = /\s/
$eof = /\$/

# note, this here includes whitespace, so be careful about where it's used
$operator = /\W/


##
# This is the list of tokens that we will be using in this here system
#
# token_list = ["T_ASSIGNMENT", "T_LBRACE", "T_RBRACE", "T_LPAREN", 
#				"T_RPAREN", "T_QUOTE", "T_BOOLOP", "T_PLUS", 
#					"T_EOFSIGN", "T_IF", "T_WHILE", "T_BOOLEAN", "T_STRING", 
#						"T_ID", "T_DIGIT", "T_PRINT", "T_TYPE"]
#


###################################################
# The main function of the entire operation
#
#

def main
# He's going to be runnin' this here operation
	
	# Retrieving that shiny input file
	input_file = File.new(ARGV[0])
	
	# Sortin' out them good lines from the bad
	input_file = IO.readlines(input_file)
	
	if input_file.length == 0
		raise BlankFileError
	end

	puts "==================================================================="
	puts "This is the captain speaking. Welcome to the 03-K64 Compiler, and now if you'll excuse me for a minute it's time to burn atmo and get this ship in the air."
	
	# Lexer it!
	puts "\nBeginnin' the Lexing process now...\n"
	token_stream = lexer(input_file)
	
	puts "\nLexing completed successfully, all tokens have been smuggled into the system\n\nToken Stream (in order):\n"
	
	# print out the received tokens
	for i in token_stream
		print i.type
		if i.type != "T_EOFSIGN"
			print ", "
		else
			puts "\n\n"
		end
	end
	
	# Parse it!
	puts "\nNow we're gonna begin the parsin'..."
	parser(token_stream)
	puts "\n\nParsing successful. We've got ourselves a nice parse stream and symbol table now.\n\n"
	
	$cst.printout
	puts "\n\n\n"
	
	puts "Now we're doin' some calculations and conversions, trying to change that CST to a nice AST...\n\n"
	
	convert_cst
	
	puts "Printing out that AST now"
	$ast.printout
	puts "\n\n"
	
	puts "We're gonna begin the semantic analysis now.\n\n"
	
	semantic_analysis
	puts "\n\n"
	$symbol_table.printout
	puts "\n\n"
	$symbol_table.analysis($symbol_table.root)
	puts "\n\n"
	puts "And now we're on to Code Generation. Here we might experience some turbulence, and possibly explode. So strap in!\n\n"
	code_gen
	
end

main