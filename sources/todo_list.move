/*
/// Module: todo_list
module todo_list::todo_list;
*/

// For Move coding conventions, see
// https://docs.sui.io/concepts/sui-move-concepts/conventions

module todo_list::todo_list;
// === Imports ===
use std::string::String;



//Error messages
#[error]
const ENotAuthorized: vector<u8> = b"The user is not authorized to perform this action";

// === Structs ===
    // Veri yapıları — örneğin görevleri temsil edecek struct burada olacak

// TodoItem – Tek Bir Görevi Temsil Eder
//TodoItem yapısında key yok çünkü bu yapı doğrudan zincire tek başına kaydedilmiyor, TodoList içinde bir **alt veri** olarak saklanıyor.
public struct TodoItem has store,drop{
    title:String,
    completed: bool,
}

// TodoList – Tüm Listeyi Temsil Eder

public struct TodoList has key
{
    id:UID,
    owner: address,
    items: vector<TodoItem>
}

  // === Public Functions ===
    // Kullanıcıların çağırabileceği fonksiyonlar (örneğin: add_task)

//Yeni Bir Liste Oluşturma
public fun new(ctx: &mut TxContext)
{
    let list = TodoList{
        id: object::new(ctx),
        owner: ctx.sender(),
        items: vector::empty(),
    };
    transfer::share_object(list);
}

//Listeye Yeni Görev Ekleme
public fun add(list: &mut TodoList, item: String)
{
    list.items.push_back(TodoItem{
        title: item,
        completed: false,
    });
}

//Görev Silme
public fun remove(list: &mut TodoList, index:u64)
{
    list.items.remove(index);
}

//Görevi Tamamlandı/Tamamlanmadı Olarak İşaretleme
public fun update_status(list: &mut TodoList, index:u64)
{
    let item = list.items.borrow_mut(index); //Belirtilen indeksdeki TodoItem’a değiştirilebilir erişim sağlar.
    item.completed = !item.completed;
}

//Listenin içini boşaltma
public fun clear(list: &mut TodoList)
{
    list.items = vector::empty<TodoItem>();
   
}

//Tüm Listeyi Silme
//Bu işlem geri alınamaz. Zincir üzerindeki obje tamamen silinir.
public fun delete(ctx: &TxContext, list : TodoList)
{ 
    let sender = ctx.sender();
    
    assert!(sender==list.owner, ENotAuthorized);
    
    let TodoList { id, owner: _,items: _ } = list;
    id.delete();
   
}