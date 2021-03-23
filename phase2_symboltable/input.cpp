#include<stdio.h>
void main()
{
	int s=1+2+3+4;
	if (s == 2) {
		s = 9;
	}
	switch (s) {
		case 2: s=4;
		case 4: s=3;
		default: 
		{
			s=2;
			if (s==2) {
				s=3;
			}
			if (s==8787) {
				s=220;
			}
			else if (s==3)
			s=100;
			else if (s==999)
			s=9998;
			else
			s=0;
		}
		case 3: s=2;
	}
}