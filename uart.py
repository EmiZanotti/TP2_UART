import serial

def recive_data(uart):
    received_data = uart.read(1)
    if received_data:
        return received_data.hex()
    return None

def get_and_send_data():
    data1 = int(input("Ingrese el primer dato (máximo 8 bits en binario): "))
    data2 = int(input("Ingrese el segundo dato (máximo 8 bits en binario): "))
    data3 = int(input("Ingrese el tercer dato (máximo 8 bits en binario): "))

    data1_bin = format(data1, '08b')
    data2_bin = format(data2, '08b')
    data3_bin = format(data3, '08b')

    return [data1_bin, data2_bin, data3_bin]
    

def main():
    uart_port = "/dev/ttyUSB0"  # Reemplaza con el puerto UART de tu sistema
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

        data = get_and_send_data()

        uart.write(bytes(data))

        print("Esperando respuesta...")
        
        respuesta = None

        while(respuesta == None):
            respuesta = recive_data(uart)

            if respuesta != None:
                print(f"Resultado ALU: {respuesta} -> {int(format(respuesta, '08b'))}")

        quit = input("Desea seguir calculando? ('exit' para salir o presione enter para continuar): ")   

        if quit == "exit":
            break     

    uart.close()

if __name__ == "__main__":
    main()
