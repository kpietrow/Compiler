#!/usr/bin/env ruby

# Works with the symbol table

class SymbolTableError < StandardError
	def initialize (id)
		puts "ERROR: Id '#{id}' was declared twice in the same scope"
		exit
	end
end

##
# Creates the Symbol Table
# This mostly just manages the Scope instances
#
class SymbolTable
	
	@root = nil
	@current_scope = nil
	
	def initialize ()
	end
	
	# returns a new layer of scope
	def enter ()
		
		if @root == nil
			new_scope = Scope.new()
			@root = new_scope
			@current_scope = @root
			
		else
			@current_scope = @current_scope.enter(@current_scope)
		end
	end
	
	def exit ()
		@current_scope = @current_scope.parent
	end
	
	def add_symbol (type, id)
		@current_scope.add_symbol(type, id)
	end
	
	# temporary
	def test ()
		@root.test
	end
	
end


##
# Creates Scope instances
# Each Scope has a Hash table of symbols
#
class Scope

	attr_accessor :children, :symbols
	attr_reader :parent, :test

	@parent = nil
	@children = []
	@symbols = nil
	@test = nil
	
	def initialize (parent = nil)
		@symbols = Hash.new
		@parent = parent
		@children = []
		@test = "hi"
	end
	
	# add symbol to symbols table
	def add_symbol (type, id)
		
		if !@symbols.has_key?(id)
			@symbols[id] = type
			
		# raise error on already defined id's
		else
			raise SymbolTableError.new(id)
		end
		
	end
	
	def enter (current)
		new_scope = Scope.new(current)
		current.children.push(new_scope)
		return new_scope
	end
	
end	
	