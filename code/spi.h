/* spi.h - SPI master interface
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>. */

#include <stdint.h>

/* OLED Screen */
#define SPI_SLAVE_SCREEN 0x00
/* Thermocouple to Digital Converter */
#define SPI_SLAVE_TCOUPLE 0x01


/* Initialize the SPI interface. */
void spi_init(void);

/* Write data to a SPI slave */
void spi_write(uint8_t slave, uint8_t *data, uint16_t count);

/* Read data from a SPI slave */
void spi_read(uint8_t slave, uint8_t *data, uint16_t count);
