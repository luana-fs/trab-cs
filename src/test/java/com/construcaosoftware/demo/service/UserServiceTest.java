package com.construcaosoftware.demo.service;

import com.construcaosoftware.demo.dtos.UserDto;
import com.construcaosoftware.demo.entity.UserEntity;
import com.construcaosoftware.demo.repository.UserRepository;
import com.construcaosoftware.demo.config.UserMapper;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.dao.DataIntegrityViolationException;

import java.time.LocalDate;
import java.util.NoSuchElementException;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class) // Inicializa o Mockito
class UserServiceTest {

    // 1. Crie "mocks" (simulações) para as dependências
    @Mock
    private UserRepository userRepository;

    @Mock
    private UserMapper userMapper;

    // 2. Injete os mocks na classe que queremos testar
    @InjectMocks
    private UserService userService;

    // --- Testes para createUser ---

    @Test
    void testCreateUser_Success() {
        // Arrange (Configuração)
        UserDto inputDto = new UserDto(null, "John", "Doe", "12345", "john@mail.com", LocalDate.now());
        UserEntity entityToSave = new UserEntity(); // Mapeado
        UserEntity savedEntity = new UserEntity(); // Salvo no BD
        savedEntity.setId(1L); // O BD gera um ID

        // Simula o comportamento dos mocks
        when(userMapper.toEntity(inputDto)).thenReturn(entityToSave);
        when(userRepository.save(entityToSave)).thenReturn(savedEntity);

        // Act (Ação)
        UserDto resultDto = userService.createUser(inputDto);

        // Assert (Verificação)
        assertNotNull(resultDto);
        // Seu método retorna o DTO de entrada, então verificamos isso.
        assertEquals(inputDto.getEmail(), resultDto.getEmail());

        // Verifica se os mocks foram chamados corretamente
        verify(userMapper, times(1)).toEntity(inputDto);
        verify(userRepository, times(1)).save(entityToSave);
    }

    @Test
    void testCreateUser_DataIntegrityViolation() {
        // Arrange
        UserDto inputDto = new UserDto(null, "John", "Doe", "12345", "john@mail.com", LocalDate.now());
        UserEntity entityToSave = new UserEntity();

        when(userMapper.toEntity(inputDto)).thenReturn(entityToSave);
        // Simula o BD lançando um erro (ex: e-mail duplicado)
        when(userRepository.save(entityToSave)).thenThrow(new DataIntegrityViolationException("Erro de integridade"));

        // Act & Assert
        // Verifica se a exceção correta é lançada
        RuntimeException exception = assertThrows(RuntimeException.class, () -> {
            userService.createUser(inputDto);
        });

        assertEquals("Error saving user", exception.getMessage());
        verify(userRepository, times(1)).save(entityToSave);
    }

    // --- Testes para getUser ---

    @Test
    void testGetUser_Success() {
        // Arrange
        Long userId = 1L;
        UserEntity foundEntity = new UserEntity();
        foundEntity.setId(userId);
        foundEntity.setEmail("test@mail.com");

        UserDto expectedDto = new UserDto(userId, "Test", "User", "111", "test@mail.com", null);

        when(userRepository.findById(userId)).thenReturn(Optional.of(foundEntity));
        when(userMapper.toDto(foundEntity)).thenReturn(expectedDto);

        // Act
        UserDto resultDto = userService.getUser(userId);

        // Assert
        assertNotNull(resultDto);
        assertEquals(expectedDto.getId(), resultDto.getId());
        assertEquals(expectedDto.getEmail(), resultDto.getEmail());
        
        verify(userRepository, times(1)).findById(userId);
        verify(userMapper, times(1)).toDto(foundEntity);
    }

    @Test
    void testGetUser_NotFound() {
        // Arrange
        Long userId = 99L;
        // Simula não encontrar o usuário
        when(userRepository.findById(userId)).thenReturn(Optional.empty());

        // Act & Assert
        NoSuchElementException exception = assertThrows(NoSuchElementException.class, () -> {
            userService.getUser(userId);
        });

        assertEquals("User not found with id " + userId, exception.getMessage());
        // Verifica que o mapper NUNCA foi chamado
        verify(userMapper, never()).toDto(any());
    }

    // --- Testes para updateUser ---

    @Test
    void testUpdateUser_Success() {
        // Arrange
        Long userId = 1L;
        UserDto updateDataDto = new UserDto(null, "Jane", "Doe", "54321", "jane@mail.com", null);
        
        // Dados que o mapper vai retornar
        UserEntity newDataEntity = new UserEntity();
        newDataEntity.setFirstName("Jane");
        newDataEntity.setEmail("jane@mail.com");
        // ... (outros campos)

        // Usuário existente no banco
        UserEntity existingUser = new UserEntity();
        existingUser.setId(userId);
        existingUser.setFirstName("John"); // Nome antigo
        existingUser.setEmail("john@mail.com"); // Email antigo

        // DTO final que será retornado
        UserDto updatedDto = new UserDto(userId, "Jane", "Doe", "54321", "jane@mail.com", null);

        when(userRepository.findById(userId)).thenReturn(Optional.of(existingUser));
        when(userMapper.toEntity(updateDataDto)).thenReturn(newDataEntity);
        when(userRepository.save(existingUser)).thenReturn(existingUser); // O save retorna a entidade atualizada
        when(userMapper.toDto(existingUser)).thenReturn(updatedDto);

        // Act
        UserDto resultDto = userService.updateUser(userId, updateDataDto);

        // Assert
        assertNotNull(resultDto);
        assertEquals("Jane", resultDto.getFirstName()); // Verifica o dado novo
        assertEquals("jane@mail.com", resultDto.getEmail()); // Verifica o dado novo

        // Verifica se os dados na entidade "existingUser" foram realmente atualizados
        assertEquals("Jane", existingUser.getFirstName());
        assertEquals("jane@mail.com", existingUser.getEmail());

        // Verifica chamadas
        verify(userRepository, times(1)).findById(userId);
        verify(userRepository, times(1)).save(existingUser);
        verify(userMapper, times(1)).toEntity(updateDataDto);
        verify(userMapper, times(1)).toDto(existingUser);
    }

    @Test
    void testUpdateUser_NotFound() {
        // Arrange
        Long userId = 99L;
        UserDto updateDataDto = new UserDto();
        
        // Simula não encontrar o usuário para atualizar
        when(userRepository.findById(userId)).thenReturn(Optional.empty());

        // Act & Assert
        NoSuchElementException exception = assertThrows(NoSuchElementException.class, () -> {
            userService.updateUser(userId, updateDataDto);
        });

        assertEquals("User not found with id " + userId, exception.getMessage());
        
        // Garante que o save e o mapper nunca foram chamados
        verify(userRepository, never()).save(any());
        verify(userMapper, never()).toEntity(any());
        verify(userMapper, never()).toDto(any());
    }

    // --- Testes para deleteUser ---

    @Test
    void testDeleteUser_Success() {
        // Arrange
        Long userId = 1L;
        when(userRepository.existsById(userId)).thenReturn(true);
        // Para métodos void, usamos o doNothing()
        doNothing().when(userRepository).deleteById(userId);

        // Act
        // O método é void, então apenas o chamamos
        userService.deleteUser(userId);

        // Assert
        // Verificamos se os métodos do repositório foram chamados na ordem correta
        verify(userRepository, times(1)).existsById(userId);
        verify(userRepository, times(1)).deleteById(userId);
    }

    @Test
    void testDeleteUser_NotFound() {
        // Arrange
        Long userId = 99L;
        when(userRepository.existsById(userId)).thenReturn(false);

        // Act & Assert
        NoSuchElementException exception = assertThrows(NoSuchElementException.class, () -> {
            userService.deleteUser(userId);
        });

        assertEquals("User not found with id " + userId, exception.getMessage());
        
        // Garante que o "delete" nunca foi chamado
        verify(userRepository, never()).deleteById(anyLong());
    }
}