import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.DatagramPacket;
import java.net.DatagramSocket;
import java.net.InetSocketAddress;

/**
 * @author Maxpicca
 * @Date 2021-11-21 19:44
 * @Description 发送方将读入的数据发送出去
 */
public class Sender implements Runnable {
    DatagramSocket socket=null;
    BufferedReader reader=null;

    private int fromPort;
    private String toIP;
    private int toPort;
    private String idName;

    /**
     * 信息发送端
     * @param fromPort 己方发送端口
     * @param toIP 对方的ip
     * @param toPort 对方接收端口
     */
    public Sender(int fromPort, String toIP, int toPort,String idName) {
        this.idName = idName;
        this.fromPort = fromPort;
        this.toIP = toIP;
        this.toPort = toPort;
        try {
            // 基于己方接口，创建数据报 socket
            socket = new DatagramSocket(this.fromPort);
            // 创建输入消息的reader
            reader = new BufferedReader(new InputStreamReader(System.in));
        } catch (Exception e) {
            e.printStackTrace();
        }
    }


    @Override
    public void run() {
        // 进程一直维持运行状态
        while(true) {
            try {
                // 输入的消息，按照字节解码
                // System.out.print(this.idName +": ");
                String msg = reader.readLine();
                byte[] buffer = msg.getBytes();
                // 创建UDP数据报，包括内容，内容长度，对方地址和对方接口
                DatagramPacket packet = new DatagramPacket(buffer, 0, buffer.length, new InetSocketAddress(this.toIP, this.toPort));
                socket.send(packet);
                // 确定程序退出条件
                if("exit".equals(msg)) {
                    break;
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        // 退出后关闭当前发出的socket
        socket.close();
    }

}