/* spi.c - SPI master interface
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
#include "spi.h"


enum ChipSelect { CS_OFF, CS_ON };

static void _spi_cs(uint8_t slave, enum ChipSelect state)
{
    uint8_t pin;

    switch (slave)
    {
        case SPI_SLAVE_SCREEN:
            pin = PC0;
            break;
        case SPI_SLAVE_TCOUPLE:
            pin = PC1;
            break;
        default:
            return;
    }

    if (state == CS_ON)
        PORTC &= ~_BV(pin);
    else
        PORTC |= _BV(pin);
}

/* Initialize the SPI interface. */
void spi_init(void)
{
    /* Enable SPI master mode, idle SCK low, sample on leading edge */
    SPCR0 |= _BV(SPE0) | _BV(MSTR0);

    /* f_sck = f_osc/2 (5 MHz) */
    SPSR0 |= _BV(SPI2X0);

    /* Enable slave select pins */
    DDRC |= _BV(PC0) | _BV(PC1);
    PORTC |= _BV(PC0) | _BV(PC1);
}

/* Write data to a SPI slave */
void spi_write(uint8_t slave, uint8_t *data, uint16_t count)
{
    _spi_cs(slave, CS_ON);

    for (uint16_t i = 0; i < count; i++)
    {
        SPDR0 = data[i];

        while (!(SPSR0 & _BV(SPIF)));
    }

    _spi_cs(slave, CS_OFF);
}

/* Read data from a SPI slave */
void spi_read(uint8_t slave, uint8_t *data, uint16_t count)
{
    _spi_cs(slave, CS_ON);

    for (uint16_t i = 0; i < count; i++)
    {
        while (!(SPSR0 & _BV(SPIF)));

        data[i] = SPDR0;
    }

    _spi_cs(slave, CS_OFF);
}
