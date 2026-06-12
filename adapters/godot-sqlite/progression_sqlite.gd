extends SceneTree
# The progression commit valve: apply the Lean script with the transcribed
# reducer, commit the profile through feat/module-sqlite (the degraded
# commit_sink), reopen the database cold, and verify the reloaded profile
# against the Lean golden.
var SCRIPT_PATH: String = OS.get_environment("PROG_SCRIPT")
var GOLDEN: String = OS.get_environment("PROG_GOLDEN")
var DB: String = OS.get_environment("PROG_DB")

var credits := 200; var affinity := 15
var items := {}   # id -> count
var arts := []

func art_cost(a: int) -> int: return {1: 100, 2: 250}.get(a, 500)
func art_req(a: int) -> int: return {1: 10, 2: 25}.get(a, 40)

func apply(ev: PackedStringArray) -> void:
	match ev[0]:
		"grant":
			var i := int(ev[1]); items[i] = items.get(i, 0) + 1
		"sell":
			var i := int(ev[1])
			if items.get(i, 0) > 0:
				credits += int(ev[2])
				items[i] -= 1
				if items[i] == 0: items.erase(i)
		"buyArt":
			var a := int(ev[1])
			if not arts.has(a) and affinity >= art_req(a) and credits >= art_cost(a):
				credits -= art_cost(a); arts.append(a)
		"train":
			affinity += 1

func _init():
	for line in FileAccess.open(SCRIPT_PATH, FileAccess.READ).get_as_text().split("\n"):
		if line != "": apply(line.split(" "))
	# commit through sqlite
	var db = SQLite.new()
	if not db.open(DB): printerr("db open failed"); quit(1); return
	for q in ["DROP TABLE IF EXISTS profile", "DROP TABLE IF EXISTS items", "DROP TABLE IF EXISTS arts",
		"CREATE TABLE profile(credits INT, affinity INT)",
		"CREATE TABLE items(id INT, cnt INT)", "CREATE TABLE arts(id INT)"]:
		db.create_query(q).execute()
	db.create_query("INSERT INTO profile VALUES (?, ?)").execute([credits, affinity])
	for i in items: db.create_query("INSERT INTO items VALUES (?, ?)").execute([i, items[i]])
	for a in arts: db.create_query("INSERT INTO arts VALUES (?)").execute([a])
	db.close()
	# cold reload
	var db2 = SQLite.new()
	db2.open(DB)
	var prof = db2.create_query("SELECT credits, affinity FROM profile").execute()[0]
	var ritems = db2.create_query("SELECT id, cnt FROM items ORDER BY rowid").execute()
	var rarts = db2.create_query("SELECT id FROM arts ORDER BY rowid").execute()
	db2.close()
	var item_s := "|".join(ritems.map(func(r): return "%d:%d" % [int(r[0]), int(r[1])]))
	var art_s := "|".join(rarts.map(func(r): return str(int(r[0]))))
	var got := "%d,%d,%s,%s" % [int(prof[0]), int(prof[1]), item_s, art_s]
	var want = FileAccess.open(GOLDEN, FileAccess.READ).get_as_text().split("\n")[1]
	if got == want:
		print("PROGRESSION SQLITE PASS: reloaded profile matches the Lean golden (", got, ")")
		quit(0)
	else:
		printerr("MISMATCH wire=", got, " golden=", want); quit(1)
