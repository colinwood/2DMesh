## Please find below my solution to creating a 2d mesh via the divide and conquer algorithm
# Given a circle of radius 2 it divides it into quads 6 levels deep and outputs the vertices 
# to a file. 


#Basic rectangle class used for creating a 2d mesh.
class Rectangle
	
	vertex_1 = []
	vertex_2 = []
	vertex_3 = []
	vertex_4 = []
	
	attr_accessor :vertex_1, :vertex_2
 
	attr_accessor :vertex_3
	attr_accessor :vertex_4
	attr_accessor :vertices
	
	def initialize(vertex_1, vertex_2, vertex_3, vertex_4)
		@vertex_1 = vertex_1
		@vertex_2 = vertex_2
		@vertex_3 = vertex_3
		@vertex_4 = vertex_4
		
		@vertices = [@vertex_1,@vertex_2,@vertex_3,@vertex_4]
	end	

	def subdivide
		top =    [(@vertex_1[0] + @vertex_2[0] )/ 2 , @vertex_1[1]] 
		right =  [@vertex_2[0], (@vertex_2[1] + @vertex_3[1]) / 2]
		bottom = [(@vertex_1[0] + @vertex_2[0]) / 2, @vertex_3[1]]
		left =   [@vertex_1[0], (@vertex_1[1] + @vertex_4[1]) / 2]
		middle = [(@vertex_1[0] + @vertex_2[0]) / 2, (@vertex_1[1] + @vertex_4[1]) / 2]
		
		top_left =     Rectangle.new @vertex_1, top, middle,left     
		top_right =    Rectangle.new top, @vertex_2, right, middle
		bottom_right = Rectangle.new middle, right, @vertex_3, bottom
		bottom_left =  Rectangle.new left, middle, bottom, @vertex_4

		[top_left,top_right, bottom_right, bottom_left]
	end

	#splits the quad into to triangles via a diagaonal line from the top left to bottom right vertex
	def to_triangles
		[[@vertex_1,@vertex_2,@vertex_3], [@vertex_3,@vertex_4,@vertex_1]]
	end
end


## Mesh class that constructs a mesh using the rectangle class provided above. 
class Mesh

	attr_accessor :mesh

	def initialize(rectangle)
		@mesh = rectangle.subdivide
	end

	def circle_mesh			
		deletes = []
		
		#subdivde any box that is not inside circle
		5.times do |x|		
		(@mesh.size).times do |x|			
			if !inside_circle? @mesh[x], 2	
				deletes << @mesh[x]
				@mesh.concat @mesh[x].subdivide			
			end					
		end	

		@mesh.each do |box|
			if outside_circle? box, 2
				deletes << box
			end
		end

		deletes.each do |d|
			@mesh.delete d
		end
		
	end	
			
	end	
	
	def inside_circle?(rectangle,radius)
		if rectangle.vertices.any? {|v| Math.sqrt(((v[0] ** 2) + (v[1] ** 2))) > radius}
			 false
		else
			 true
		end			
	end

	def outside_circle?(rectangle, radius)
		if rectangle.vertices.any? {|v| Math.sqrt(((v[0] ** 2) + (v[1] ** 2))) < radius }
			 false
		else
			 true
		end
	end
end




def question1
	rectangle = Rectangle.new [-2.0,2.0], [2.0,2.0], [2.0,-2.0], [-2.0,-2.0]
	m = Mesh.new(rectangle)
	m.circle_mesh


	x_values = []
	y_values = []

	triangles = []
	m.mesh.each do |box|
		triangles.concat box.to_triangles
		
	end

	c = File.open("indexed_faces.txt", "w")
	f = File.open("points.txt", 'w')
	triangles.each_with_index do |triangle, index|
		triangle.each {f.puts "#{triangle[0][0]} #{triangle[0][1]}\n#{triangle[1][0]} #{triangle[1][1]}\n#{triangle[2][0]} #{triangle[2][1]}"}
	end
	f.close
	f = File.open("points.txt", 'r')
	f.each_with_index do |line,index| 
		c.print "#{index + 1} "
		if (index + 1) % 3 == 0
			c.puts 
		end
	end
	f.close
	c.close

	triangles
end



# The code below was used to add 250 additional points to the original circle2d-outer.node file. 
# if you place that file into the director where this program is located and run this method 
# you will see 250 addtional random points added to the file. If you run it again it will overwrite my existing
# file so don't unless you start with a fresh copy of circle2d-outer.node.

# def question2
# 	f = File.open("circle2d-outer.node", "r+")	
# 		f.each {|line| puts line}
# 		250.times do |k| 
# 			x = Random.new.rand(-0.9999999...0.9999999)
# 			y = Random.new.rand(-0.9999999...0.9999999)
# 			until x ** 2 + y ** 2 < 1 do				
# 				  x = Random.new.rand(-0.9999999...0.9999999) 
# 				  y = Random.new.rand(-0.9999999...0.9999999)			
# 		    end
# 			f.write "\n#{k + 63} #{x} #{y}"
# 		end
# 	f.close
# end


# This class has all the helper method created to solve the problems in assignment7 question3. 
class Question3

	def aspect_ratio_quality(edges)
			
		longest_edge = [edges[0], edges[1], edges[2]].max  
		smallest_edge = [edges[0], edges[1], edges[2]].min  

		longest_edge / smallest_edge 

	end

	def circumcircle_quality(edges)
		0.5 * edges.max / radius_of_circumscribing_circle(edges)
	end	

	def area_lrms_quality(edges)
		herons_area(edges) / lrms_squared(edges)
	end



	## Below you wil find the helper mehtods used to calculate the 3 different quality metrics for a 
	#  triangle given 3 edges

	def lrms_squared(edges)
		(1 / 3) * (edges[0] ** 2) + (edges[1] ** 2) + (edges[2] ** 2)
	end

	def herons_area(edges)
		Math.sqrt( p(edges) * (p(edges) - edges[0]) * (p(edges) - edges[1]) * (p(edges) - edges[2]))
	end

	def p(edges)
		(edges[0] + edges[1] + edges[2]) / 2
	end	
	def radius_of_circumscribing_circle(edges)
		(edges[0] * edges[1] * edges[2] ) / Math.sqrt((edges[0] + edges[1] + edges[2]) * (edges[1] + edges[2] - edges[0]) * (edges[2] + edges[0] - edges[1]) * (edges[0] + edges[1] - edges[2]))
	end

	def edges(vertex_1,vertex_2,vertex_3)

		edge1 = distance(vertex_1[0],vertex_2[0], vertex_1[1],vertex_2[1])
		edge2 = distance(vertex_2[0],vertex_3[0], vertex_2[1],vertex_3[1])
		edge3 = distance(vertex_3[0],vertex_1[0], vertex_3[1],vertex_1[1])	

		[edge1,edge2,edge3]
	end

	def distance(x1,x2,y1,y2)
		Math.sqrt(((x2 - x1) ** 2) + ((y2 - y1) ** 2))
	end
end


## Method that processes the data output from matlab as well as the 2d mesh generated and 
# generates quality reports for each and every triangle in the mesh. 
def question3
	q3 = Question3.new()

	q1_triangles = question1
	
	q2_triangles = File.open("Question2Triangles.txt", 'r')
	q3_triangles = File.open("Question3Triangles.txt", 'r')
	

	q1_quality_report = File.open("q1_quality_report.txt", "w")
	q2_quality_report = File.open("q2_quality_report.txt", "w")
	q3_quality_report = File.open("q3_quality_report.txt", "w")

	#q1_quality_report.puts("Triangle Index, Aspect Ratio Quality, Circumscribing Circle Quality, Root Mean Squared Quality")
	#q2_quality_report.puts("Triangle Index, Aspect Ratio Quality, Circumscribing Circle Quality, Root Mean Squared Quality")
	#q3_quality_report.puts("Triangle Index, Aspect Ratio Quality, Circumscribing Circle Quality, Root Mean Squared Quality")

	q1_triangles.each_with_index do |t, index|	
		edges = q3.edges(t[0], t[1], t[2])
		q1_quality_report.puts("#{index}, #{q3.aspect_ratio_quality(edges)}, #{q3.circumcircle_quality(edges)}, #{q3.area_lrms_quality(edges)} ")
	end

	q2_triangles.each_with_index do |triangle, index|
		vertex_1 = triangle.split(" ")[0]
		vertex_1_x = vertex_1.split(",")[0].to_f 
		vertex_1_y = vertex_1.split(",")[1].to_f 


		vertex_2 = triangle.split(" ")[1]
		vertex_2_x = vertex_2.split(",")[0].to_f
		vertex_2_y = vertex_2.split(",")[1].to_f 


		vertex_3 = triangle.split(" ")[2]
		vertex_3_x = vertex_3.split(",")[0].to_f 
		vertex_3_y = vertex_3.split(",")[1].to_f
		
		edges = q3.edges([vertex_1_x, vertex_1_y],[vertex_2_x, vertex_2_y], [vertex_3_x, vertex_3_y])
		q2_quality_report.puts("#{index}, #{q3.aspect_ratio_quality(edges)}, #{q3.circumcircle_quality(edges)}, #{q3.area_lrms_quality(edges)} ")

	end

	q3_triangles.each_with_index do |triangle, index|
		vertex_1 = triangle.split(" ")[0]
		vertex_1_x = vertex_1.split(",")[0].to_f 
		vertex_1_y = vertex_1.split(",")[1].to_f 


		vertex_2 = triangle.split(" ")[1]
		vertex_2_x = vertex_2.split(",")[0].to_f
		vertex_2_y = vertex_2.split(",")[1].to_f 


		vertex_3 = triangle.split(" ")[2]
		vertex_3_x = vertex_3.split(",")[0].to_f 
		vertex_3_y = vertex_3.split(",")[1].to_f
		
		edges = q3.edges([vertex_1_x, vertex_1_y],[vertex_2_x, vertex_2_y], [vertex_3_x, vertex_3_y])
		q3_quality_report.puts("#{index}, #{q3.aspect_ratio_quality(edges)}, #{q3.circumcircle_quality(edges)}, #{q3.area_lrms_quality(edges)} ")

	end
end

question1
question3
