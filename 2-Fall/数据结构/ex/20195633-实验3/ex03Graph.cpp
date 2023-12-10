#include<iostream>
#include<queue>
#include<stack>
using namespace std;

const int INF = 0x7fffffff;
enum Visit{ UNVISITED, VISITED };

class Graph{
private:
    void operator = (const Graph&) {}
    Graph(const Graph&) {}

public:
    Graph(){}
    virtual ~Graph() {}
    virtual void Init(int n) = 0;
    virtual int n() = 0;
    virtual int e() = 0;
    virtual int first(int v) = 0; // the first neighbor of v
    virtual int next(int v, int w) = 0; // the next neighbor of v
    virtual void setEdge(int v1, int v2, int wght) = 0;
    virtual void delEdge(int v1, int v2) = 0;
    virtual bool isEdge(int i, int j) = 0;
    virtual int weight(int v1, int v2) = 0;
    virtual int getMark(int v) = 0;
    virtual void setMark(int v, int val) = 0;
};

class MGraph{
private:
    int numV, numE;
    int **matrix;
    int *mark;
public:
    MGraph(int numV){ Init(numV); }
    ~MGraph(){
        delete[] mark;
        for (int i = 0; i <= numV;i++) delete[] matrix[i];
        delete[] matrix;
    }
    void Init(int n){
        numV = n;
        numE = 0;
        mark = new int[numV+1];
        matrix = (int **)new int *[numV+1];
        for (int i = 0; i <= numV;i++){
            mark[i] = UNVISITED;
            matrix[i] = new int[numV+1];
            for (int j = 0; j <= numV;j++) 
                matrix[i][j]=INF;
        }
    }
    int n() { return numV; }
    int e() { return numE; }
    int first(int v){
        for (int i = 1; i <= numV;i++)
            if(matrix[v][i]!=INF) return i;
        return numV+1;
    }
    int next(int v,int w){
        for (int i = w+1; i <= numV;i++)
            if(matrix[v][i]!=INF) return i;
        return numV+1;
    }
    void setEdge(int u,int v,int w){
        // Assert(w > 0, "负数权重出现");
        if(matrix[u][v]==INF) numE++;
        matrix[u][v] = w;
    }
    void delEdge(int u,int v){
        if(matrix[u][v]!=INF) numE--;
        matrix[u][v] = INF;
    }
    bool isEdge(int u,int v){ return matrix[u][v] != INF; }
    int weight(int u, int v) { return matrix[u][v]; }
    int getMark(int u) { return mark[u]; }
    void setMark(int u, int val) { mark[u] = val; }

    void printBFS(int s){
        // 每一步操作都需要重置mark
        fill(mark, mark + numV + 1, UNVISITED);
        queue<int> q;
        mark[s] = VISITED;
        cout << s;
        q.push(s);
        while(!q.empty()){
            int t = q.front();
            q.pop();
            for (int i = 1; i <= numV;i++){
                if(matrix[t][i] != INF && mark[i]==UNVISITED){
                    cout << " " << i;
                    q.push(i);
                    mark[i] = VISITED;
                }
            }
        }
        cout << endl;
    }

    void printDFS(int s){
        static bool flag = true; // 是否是第一个元素
        if(flag){
            fill(mark, mark + numV + 1, UNVISITED); // mark重置
            cout << s;
        } 
        else cout << " " << s; 
        mark[s]=VISITED;
        for (int i = first(s); i <= numV;i = next(s,i)){
            flag = false;
            if(mark[i]==UNVISITED && i<=numV)
                printDFS(i);
        }
    }

    void printDijkstra(int s,int*d,int *parent){
        fill(mark, mark + numV + 1, UNVISITED);
        fill(parent, parent + numV + 1, -1);
        for (int i = 1; i <= numV;i++){
            d[i] = matrix[s][i];
            if(d[i]!=INF) parent[i]=s;
        }
        d[s] = 0;
        mark[s] = VISITED;
        while(true){
            int v=-1, min = INF;
            for (int i = 1; i <= numV;i++){
                if(d[i]<min && mark[i]==UNVISITED){
                    v = i;
                    min = d[i];
                }
            }
            if(v==-1) break;
            mark[v]=VISITED;
            for (int i = first(v); i <= numV;i=next(v,i)){
                if(d[i]>d[v]+matrix[v][i]){
                    d[i] = d[v] + matrix[v][i];
                    parent[i] = v; // 记路径上i的parent为v
                }
            }
        }
        // 路径打印
        for (int i = 1; i <= numV;i++){
            stack<int> spath;
            if(i == s) continue;
            if(d[i]==INF || i == s) {
                cout<<"0"<<endl;
                continue;
            }
            int temp = i;
            while(1){
                if(temp==-1) break;
                spath.push(temp);
                temp = parent[temp];
            }
            while(!spath.empty()){
                cout << spath.top() << " ";
                spath.pop();
            }
            cout << d[i] << endl;
        }
    }

    void printPrim(){
        int parent[numV+1];
        int d[numV + 1];
        int pu[numV + 1];
        int pv[numV + 1];
        int pw[numV + 1];
        int count = 0;
        for (int i = 0; i <= numV;i++){
            mark[i] = UNVISITED;
        }
        int s = -1, min = INF;
        // 找到最小的节点（最小生成树）
        for (int i = 1; i <= numV;i++){
            for (int j = 1; j <= numV;j++){
                if(matrix[i][j]<min) {
                    s = i;
                    min = matrix[i][j];
                }
            }
        }
        // 数据初始化
        for (int i = 1; i <= numV;i++){
            d[i] = matrix[s][i];
            parent[i] = s;
        }
        d[s] = 0;
        mark[s] = VISITED;
        while(true){
            int v=-1, min = INF;
            for (int i = 1; i <= numV;i++){
                if(d[i]<min && mark[i]==UNVISITED){
                    v = i;
                    min = d[i];
                }
            }
            if(v==-1) break;
            pu[count] = parent[v]<v?parent[v]:v;
            pv[count] = parent[v]>v?parent[v]:v;
            pw[count++] = matrix[parent[v]][v];
            mark[v]=VISITED;
            for (int i = first(v); i <= numV;i=next(v,i)){
                if(d[i] > matrix[v][i]){
                    d[i] = matrix[v][i];
                    parent[i] = v; // 记路径上i的parent为v
                }
            }
        }
        // 排序打印输出
        for (int i = 0;i<count;i++){
            for (int j = i + 1;j<count;j++){
                if(pw[i]>pw[j] || (pw[i]==pw[j]&&pu[i]>pu[j])) {
                    swap(pu[i], pu[j]);
                    swap(pv[i], pv[j]);
                    swap(pw[i], pw[j]);
                    // int temp;
                    // temp = pu[i];pu[i] = pu[j];pu[j] = temp;
                    // temp = pv[i];pv[i]=pv[j];pv[j]=temp;
                    // temp = pw[i];pw[i]=pw[j];pw[j]=temp;
                }
            }
        }
        for (int i = 0;i<count;i++){
            cout << pu[i] << " " << pv[i] << " " << pw[i] << endl;
        }
    }
    
    bool tophelp(){
        // 无向图判断是否有环
        queue<int> task;
        int count[numV + 1];
        for (int i = 1; i <= numV;i++) count[i] = 0;
        for (int i = 1; i <= numV;i++){
            for (int j = 1; j <= numV;j++){
                if(matrix[i][j]!=INF) count[j]++;
            }
        }
        for (int i = 1; i <= numV;i++){
            if(count[i]==0 || count[i]==1) task.push(i);
        }
        while(!task.empty()){
            int t = task.front();
            task.pop();
            for (int i = 1; i <= numV;i++){
                if(matrix[t][i]!=INF) count[i]--;
                if(count[i]==0 || count[i]==1) task.push(i);
            }
        }
        for (int i = 1; i <= numV;i++){
            if(count[i]>1) return true; // 有环
        }
        return false; // 无环
    }
};

int main(){
    int n, m;
    cin >> n >> m;
    MGraph mGraph(n);
    for (int i = 0; i < m;i++){
        int u, v, w;
        cin >> u >> v >> w;
        mGraph.setEdge(u, v, w);
        mGraph.setEdge(v, u, w);
    }
    mGraph.printBFS(1);
    mGraph.printDFS(1);
    cout << "\n"; 
    int d[n+1];
    int parent[n+1];
    int s = 1;
    mGraph.printDijkstra(s, d, parent);
    mGraph.printPrim();
    if(mGraph.tophelp()) cout<<"YES";
    else cout << "NO";
    return 0;
}