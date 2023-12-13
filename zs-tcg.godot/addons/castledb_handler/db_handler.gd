@icon("db_handler.svg")
class_name DataBaseHandler extends Node
##Used to handler json files made with castle db.




var old_db:Dictionary

var Database : Dictionary = {}
##Path to a json file with card info
@export_file() var database_path : String:
	set(path):
		if path != database_path:
			database_path=path
			#db = load_db()
			#Rearange database for easier use
			Database = format_db()

var og_db


var valid_file:=false:
	get:
		if valid_file: return true
		else: 
			return false



func format_db() -> Dictionary:
	if FileAccess.file_exists(database_path):
		var file = FileAccess.open(database_path, FileAccess.READ)
		var json = JSON.parse_string(file.get_as_text())
		if json.has("sheets"): 
			
			var n=0
			var sheets := {}
			og_db = json["sheets"]
			for s in og_db: # Cycle through each sheet, format it and add it to the db
				var unique_id
				for column in s["columns"]: #Find any unique ids in the sheet
					if column["typeStr"]=="0":
						unique_id=column["name"]
						break
					else:
						unique_id=null
				sheets[s["name"]] = restablish_ids(n,unique_id)
				n=+1
			valid_file=true
			return sheets
		else:
			push_warning("Card Data Base File is not formatted correctly.")
			return {}
	else:
		push_warning("Json file does not exists.")
		return {}


func restablish_ids(sheet_index:int,unique_id:Variant) -> Dictionary:
	var row = {}
	if unique_id != null:
		for l in og_db[sheet_index]["lines"]: # Add unique id for each row
			if l.has(unique_id):
				row[l[unique_id]] = l
			else: break
	else:
		var id:=0
		for l in og_db[sheet_index]["lines"]: # Add id number for each row
			l["sheet_id"] = id
			row[id] = l
			id+=1
	return row



	
func retrive_attributes(sheet:String,id_name:Variant) -> Dictionary:
	if valid_file:
		if Database.has(sheet):
			if Database[sheet].has(id_name):
				return Database[sheet][id_name]
			else:
				push_warning(" \"" + id_name + "\" was not found in + \"" + sheet + "\"." )
				return {}
		else:
			push_warning(" \"" + sheet + "\" was not found in database.")
			return {}
	else:
		push_warning("Json file is in valid.")
		return {}
	
func sort_sheet_by_attribute(sheet:String,attribute:String,value:Variant) -> Dictionary:
	if valid_file:
		if Database.has(sheet):
			var table:={}
			var n:=0
			for i in Database[sheet].values():
				if i.has(attribute):
					if i[attribute] == value:
						table[n] = i
						n+=1
			return table
		else:
			push_warning(" \"" + sheet + "\" was not found in database.")
			return {}
	else:
		push_warning("Json file is in valid.")
		return {}
	
func get_ref_id_from_table(id:int,table:Dictionary) -> int:
	if valid_file:
		var _i:=0
		if table.has(id):
			return table[id]["sheet_id"]
		else:
			return -1
	else: return -1
