import serial

def receive_data(uart):
    received_data = uart.read(1)
    if received_data:
        return received_data
    return None

def send_data(uart):
    data1 = int(input("Ingrese el primer dato (máximo 8 bits en binario): "))
    data1_bin = data1.to_bytes(1, 'big')
    print(data1_bin)
    uart.write(data1_bin)
    data2 = int(input("Ingrese el segundo dato (máximo 8 bits en binario): "))
    data2_bin = data2.to_bytes(1, 'big')
    print(data2_bin)
    uart.write(data2_bin)
    data3 = int(input("Ingrese el tercer dato (máximo 8 bits en binario): "))
    data3_bin = data3.to_bytes(1, 'big')
    print(data3_bin)
    uart.write(data3_bin)

def ascii_to_binary(ascii):
    value = ord(ascii)
    return "{0:08b}".format(value)

def main():
    uart_port = "/dev/ttyUSB1"  # Reemplaza con el puerto UART de tu sistema
    uart_baudrate = 9600
    uart_data_bits = 8
    uart_parity = 'N'
    uart_stop_bits = 1

    try:
        uart = serial.Serial(
            uart_port,
            baudrate=uart_baudrate,
            bytesize=uart_data_bits,
            parity=uart_parity,
            stopbits=uart_stop_bits
        )
    except serial.SerialException as e:
        print(f"Error al abrir la conexión {e}")
        return

    while True:

        send_data(uart)

        print("Esperando respuesta...")
        
        respuesta = None

        while(respuesta == None):
            respuesta = receive_data(uart)

            if respuesta != None:
                print(f"Resultado ALU: {int.from_bytes(respuesta, 'big')}")

if __name__ == "__main__":
    main()
