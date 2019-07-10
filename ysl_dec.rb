$table=[]

def llong(file)
	return file.read(4).unpack("V").join.to_i
end

def bytess(file)
	return file.read(1).unpack("C").join.to_i
end

class L18VFS
	def initialize(file_name)
		if FileTest.exist?(file_name)
			@hd_file=File.open(file_name,"rb")
		else
			raise "#{file_name} is not have"
		end
		head_size=bytess(@hd_file)
		if head_size < 10
			head_strr=@hd_file.read(head_size).to_s
			case head_strr
			when "L18VFSH"
				table_info(@hd_file)
			else
				raise "unknow file,not is L18VFS type"
			end
		else
			raise "#{file_name} is not L18VFS file"
		end
	end
	def l18_strr(file)
		strr_size=bytess(file)
		ry_strr=bytess(file)
		if ry_strr != 1
			return ([ry_strr].pack("C").to_s)+file.read(strr_size-1).to_s
		else
			return file.read(strr_size).to_s
		end
	end
	def table_info(file)
		file_count=llong(file)
		for i in 0..(file_count-1)
		#i=0
		#loop do
			file_name=l18_strr(file)
			crc=llong(file).to_s(16)
			zeero=llong(file).to_s(16)
			#puts zeero
			if zeero != "0"
				return
			end
			size1=llong(file)
			size2=llong(file)
			$table[i]=[file_name,size1,size2]
		#	i+=1
		#	if file.pos == file.size
		#		break
		#	end
		end
		#puts i
	end
end

def fix_dir(sz)
	p=[]
	for i in 0..(sz.size-2)
		if i == 0
			p[0]=sz[0]
		else
			tmp_p=[]
			for ii in 0..i
				tmp_p[ii]=sz[ii]
			end
			p[i]=tmp_p.join("/")
		end
	end
	return p
end

def mk_dirr(strr)
	folder_wz=fix_dir(strr.split("/"))
	for i in 0..(folder_wz.size-1)
		if File::directory?(folder_wz[i])
			#puts "#{folder_wz[i]} is exist"
		else
			Dir.mkdir(folder_wz[i])
		end
	end
end

def save_file_data(file_name,size)
	if FileTest.exist?(file_name)
	else
		puts "save #{file_name}"
		pp=File.open(file_name,"wb")
		pp.print $sdata_data.read(size)
		pp.close
	end
end
sdata_table=L18VFS.new("StreamingData.hd")
if FileTest.exist?("StreamingData")
	$sdata_data=File.open("StreamingData","rb")
	data_head_size=bytess($sdata_data)
	if data_head_size < 10
		head_strr=$sdata_data.read(data_head_size).to_s
		if head_strr == "L18VFS"
			$table.each do |file_name,size1,size2|
				mk_dirr(file_name)
				save_file_data(file_name,size1)
			end
		else
			raise "not is L18VFS file"
		end
	else
		raise "not is L18VFS file"
	end
else
	raise "StreamingData is not have"
end
