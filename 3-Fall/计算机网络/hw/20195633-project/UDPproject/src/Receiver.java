import java.net.DatagramPacket;
import java.net.DatagramSocket;
import java.net.SocketException;

/**
 * @author Maxpicca
 * @Date 2021-11-21 19:42
 * @Description 接收方将收到的数据输出
 */
public class Receiver implements Runnable {
    DatagramSocket socket=null;
    private int myPort;
    private String idName;

    /**
     * 信息接收端
     * @param myPort 己方接收端口
     * @param idName 对方信息
     */
    public Receiver(int myPort,String idName) {
        this.myPort = myPort;
        this.idName = idName;
        try {
            // 创建己方接收的数据报socket
            socket = new DatagramSocket(this.myPort);
        } catch (SocketException e) {
            e.printStackTrace();
        }
    }

    @Override
    public void run() {
        while(true) {
            try {
                byte[] buffer = new byte[1024];
                DatagramPacket packet = new DatagramPacket(buffer, 0, buffer.length);
                // 获取数据报
                socket.receive(packet);
                // 数据报的数据字段(byte格式)
                byte[] data = packet.getData();
                // byte转为字符串
                String msg = new String(data,0,data.length);
                // 接收消息
                System.out.println(this.idName+": "+msg);

                if("exit".equals(msg)) {
                    break;
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        // 关闭接收窗口
        socket.close();
    }

}
