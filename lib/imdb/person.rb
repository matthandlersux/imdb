module Imdb

	class Person
		attr_accessor :id, :url, :name, :primary_role

		def initialize(id, name, primary_role)
			@id = id
			@name = name
			@primary_role = primary_role
		end

	end

end