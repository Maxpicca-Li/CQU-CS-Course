#include<iostream>
using namespace std;

template<typename E>class List{ // List ADT
private:
    void operator=(const List&){}
    List(const List&){}
public:
    List(){}
    virtual ~List(){}

    virtual void clear() = 0; //纯虚函数，抽象类，定义统一函数功能接口
    virtual void insert(const E &item) = 0;
    virtual void append(const E &item) = 0;
    virtual E remove() = 0; //移除curr的结点，并返回结点值
    virtual void moveToStart() = 0; //set the curr to the head(start of the list)
    virtual void moveToEnd() = 0; //set the curr to the tail(end of the list)
    virtual void prev() = 0; //move the current position one step left
    virtual void next() = 0; //move the current position one step right
    virtual int length() const = 0;
    virtual int currPos() const = 0; // the index of the current position
    virtual void moveToPos(int pos) = 0;
    virtual E &getValue() const = 0;
};

template<typename Multi, typename Power> class Nomial{
public:
    Multi multi;
    Power power;
    Nomial(){} // 无参构造
    Nomial(Multi mm,Power pp){ // 参数构造
        multi = mm;
        power = pp;
    }
    Nomial(const Nomial& it){ // 拷贝函数构造
        multi = it.multi;
        power = it.power;
    }
    void operator =(const Nomial& it){ // 重载"="赋值运算符
        multi = it.multi;
        power = it.power;
    }    
};

template<typename E> class Link{ // 结点类
private:
    static Link<E> *freelist; //一个结点模块
public:
    E element;
    Link *prev;
    Link *next;
    Link(const E& it,Link *pr,Link *ne){ // 有参构造函数
        element = it; // 对应等号重载运算符
        prev = pr;
        next = ne;
    }
    Link(Link *pr=NULL,Link *ne=NULL){ // 无参&有参构造函数（初始化）
        prev = pr;
        next = ne;
    }
    void* operator new(size_t){ // new运算重载
        if(freelist==NULL)
            return ::new Link; // creat place
        Link<E> *temp = freelist;
        freelist = freelist->next;
        return temp;
    }
    void operator delete(void *ptr){  //delete运算重载
        ((Link<E> *)ptr)->next = freelist;
        freelist = (Link<E> *)ptr;
    }
};
template<typename E> Link<E>* Link<E>::freelist = NULL; // freelist静态变量初始化

template<typename E> class DLList: public List<E>{
private:
    Link<E> *head; 
    Link<E> *curr; // Behind the current element,is what we do with
    Link<E> *tail;
    int len;
    void init(){
        head = new Link<E>;
        tail = new Link<E>;
        head->next = tail;
        tail->prev = head;
        curr = head;
        len = 0;
    }

    void removeall(){
        while(head!=NULL){
            curr = head;
            head = head->next;
            delete curr; // delete one by one from the strat of the list
        }
    }

public:
    DLList() { init(); } // Constructors
    ~DLList() { removeall(); } // Destructor
    void clear() { removeall(); init(); }
    void insert(const E& it) { // add it after the current point
        curr->next = curr->next->prev = new Link<E>(it,curr,curr->next);
        len++;
    }
    void append(const E& it){ // add it to the end of the list
        tail->prev = tail->prev->next = new Link<E>(it,tail->prev,tail);
        len++;
    }
    E remove(){ // remove the curr->next node
        E it = curr->next->element;
        Link<E> *temp = curr->next;
        curr->next->next->prev = curr;
        curr->next = curr->next->next;
        delete temp;
        len--;
        return it;
    }
    void moveToStart(){
        curr = head;
    }
    void moveToEnd(){
        curr = tail->prev;
    }
    void prev(){
        if (curr != head)
            curr = curr->prev;
    }
    void next(){
        if (curr->next != tail)
            curr = curr->next;
    }
    int length() const{ return len; }
    int currPos()const{
        Link<E> *temp = head;
        int i;
        for (i = 0; curr != temp;i++){
            temp = temp->next;
        }
        return i;
    }
    void moveToPos(int pos){
        if(pos<0 || pos>=len) {
            cout << "Position out of range";
            return;
        }
        curr = head;
        for (int i = 0; i < pos;i++)
            curr = curr->next;
    }
    E& getValue() const{
        if(curr->next != tail)
            return curr->next->element;  //这是给的curr后面的值！！！
    }
};

void add(DLList<Nomial<int,int>>& addres, DLList<Nomial<int,int>>& A, DLList<Nomial<int,int>>& B){
    Nomial<int, int> temp;
    A.moveToStart();
    for (int i = 0; i < A.length();){
        addres.append(A.getValue());
        A.next();
        i++;
    }
    addres.moveToStart();
    B.moveToStart();
    for (int i = 0; i < B.length();){
        if(B.getValue().power > addres.getValue().power){
            addres.insert(B.getValue()); // address.getValue指的就是后面一个结点的数值，直接insert插入在后面就行
            B.next();
            i++;
            addres.next(); // 回到判断时的address位置
        }
        else if(B.getValue().power == addres.getValue().power){
            addres.getValue().multi += B.getValue().multi;
            B.next();
            i++;
        }
        else {
            addres.next();
        }
    }
}
void mul(DLList<Nomial<int,int>>& mulres, DLList<Nomial<int,int>>& A, DLList<Nomial<int,int>>& B){
    Nomial<int, int> temp;
    A.moveToStart();
    
    for (int i = 0; i < A.length();){
        B.moveToStart();
        for (int j = 0; j < B.length();){
            temp.multi = A.getValue().multi * B.getValue().multi;
            temp.power = A.getValue().power + B.getValue().power;
            mulres.append(temp);
            B.next();
            j++;
        }
        A.next();
        i++;
    }
}

void print(DLList<Nomial<int,int>>& A){ //自测通过
    A.moveToStart();
    for (int i = 0; i < A.length();){
        cout << A.getValue().multi << " " << A.getValue().power << endl;
        A.next();
        i++;
    }
}
void sort(DLList<Nomial<int,int>>& A){ // 自测通过+去0功能+去重功能
    A.moveToStart();
    Nomial<int, int>* sign;
    Nomial<int, int> temp;
    for (int i = 0; i < A.length()-1; i++){
        A.moveToPos(i);
        sign = & A.getValue();
        if(A.getValue().multi == 0){
            A.remove();
        }
        for (int j = i + 1; j < A.length();j++){
            A.moveToPos(j);  //类似数组a[j]，实际上所指的数值是第j+1的数值
            if(A.getValue().power > sign->power){
                temp = A.getValue();
                A.getValue() = *sign;
                sign->power = temp.power;
                sign->multi = temp.multi;
            }
            else if(A.getValue().power == sign->power){
                sign->multi += A.getValue().multi;
                A.getValue().multi = 0;
            }
        }
    }
}
int main(){
    int Na, Nb;
    cin >> Na >> Nb;
    DLList<Nomial<int,int>> A;
    DLList<Nomial<int,int>> B;
    DLList<Nomial<int,int>> addres;
    DLList<Nomial<int,int>> mulres;
    Nomial<int,int> it;
    for (int i = 0; i < Na;i++){
        int multi, power;
        cin >> multi >> power;
        it.multi=multi;
        it.power=power;
        A.append(it); 
    }
    for (int i = 0; i < Nb;i++){
        int multi, power;
        cin >> multi >> power;
        it.multi=multi;
        it.power=power;
        B.append(it); 
    }
    sort(A);
    sort(B);
    add(addres,A, B);
    cout << addres.length() << endl;
    print(addres);

    mul(mulres, A, B);
    sort(mulres);
    cout << mulres.length() << endl;
    print(mulres);
}