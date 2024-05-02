import Map "mo:base/HashMap";
import Hash "mo:base/Hash";
import Nat "mo:base/Nat";
import Text "mo:base/Text";
import Iter "mo:base/Iter";
//smart contract actor keyi ile oluşturuluyor.
//smart contract => canister(icp)
actor {
  type ToDo = {
    description : Text;
    completed : Bool;
  };
  //basit data türleri: text->string, boolean-
  //Nat natural Number (int)
  func natHash(n : Nat) : Hash.Hash {
    Text.hash(Nat.toText(n)) // ...
  };
  // degiskenler
  // let -> immutable
  // var -> mutable
  // const-> global

  var todos = Map.HashMap<Nat, ToDo>(0, Nat.equal, natHash);
  var nextId : Nat = 0;

  //func -> private
  //public query func -> sorgulama
  //public fun -> update

  public query func getTodos() : async [ToDo] {
    Iter.toArray(todos.vals());
  };

  public func addToDo(description : Text) : async Nat {
    let id = nextId;
    todos.put(id, { description = description; completed = false });
    nextId += 1;
    return id;
  };

  public func completeToDo(id : Nat) : async () {
    ignore do ? {
      let description = todos.get(id)!.description;
      todos.put(id, { description; completed = true });
    };
  };

  public query func showToDos() : async Text {
    var output : Text = "\n______TO-DOs_______";
    for (toDo : ToDo in todos.vals()) {
      output #= "\n" # toDo.description;
      if (toDo.completed) { output #= " !" };
    };
    output # "\n";
  };

  public func clearCompleted() : async () {
    todos := Map.mapFilter<Nat, ToDo, ToDo>(
      todos,
      Nat.equal,
      natHash,
      func(_, todo) { if (todo.completed) null else ?todo },
    );
  };
};
